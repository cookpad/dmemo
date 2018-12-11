require "google/cloud/bigquery"

module DataSourceAdapters
  class BigqueryAdapter < Base
    def fetch_table_names
      latest_table_names.keys.map do |prefix|
        [bq_dataset.dataset_id, prefix]
      end
    end

    def fetch_columns(table)
      bq_table = bq_table(table)
      flatten_fields(bq_table.fields, '')
    end

    def fetch_rows(table, limit)
      bq_table = bq_table(table)
      return [] if bq_table.gapi.type == 'VIEW' || bq_table.gapi.type == 'MODEL'

      bq_table.data(max: limit).map do |row|
        extract_row_data(row, bq_table.fields)
      end
    end

    def fetch_count(table)
      bq_table = bq_table(table)
      bq_table.rows_count
    end

    def disconnect_data_source!
      @bq_dataset = nil
      @latest_table_names = nil
    end

    def reset!
      disconnect_data_source!
    end

    private

    def bq_dataset
      return @bq_dataset if @bq_dataset

      config = @data_source.bigquery_config
      client = config.credentials ?
        Google::Cloud::Bigquery.new(
          project_id: config.project_id,
          credentials: JSON.parse(config.credentials),
        ) :
        Google::Cloud::Bigquery.new(
          project_id: config.project_id,
        )

      @bq_dataset = client.dataset(config.dataset)
      raise DataSource::ConnectionBad.new("dataset \"#{config.dataset}\" not found") if @bq_dataset.nil?

      @bq_dataset
    end

    def bq_table(table)
      bq_dataset.table(latest_table_names[table.table_name])
    end

    def latest_table_names
      return @latest_table_names if @latest_table_names

      @latest_table_names = {}

      fetch_all_table_ids.group_by { |table_id|
        match = table_id.match(/(.*)\d{8}\z/) # bigquery partitoned table name suffix is 'yyyymmdd'
        match ? match[1] : table_id
      }.each do |prefix, ids|
        @latest_table_names[prefix] = ids.max # take the latest partitoned table name
      end

      @latest_table_names
    end

    def fetch_all_table_ids
      bq_dataset.tables(max: 1000).all.map(&:table_id)
    end

    def flatten_fields(fields, field_prefix)
      result = []

      fields.each do |field|
        nullable = field.mode.nil? || field.mode == 'NULLABLE'
        type = field.mode == 'REPEATED' ? "#{field.type}[]" : field.type
        result << Column.new("#{field_prefix}#{field.name}", type, '', nullable)

        result.concat(flatten_fields(field.fields, "#{field_prefix}#{field.name}.")) if field.type == 'RECORD'
      end
      result
    end

    def extract_row_data(row, fields)
      result = []

      fields.each do |field|
        value = row[field.name.to_sym]
        if field.type == 'RECORD'
          result << ''
          if value.is_a? Array
            next_row = value.first || {}
            result.concat(extract_row_data(next_row, field.fields))
          else
            result.concat(extract_row_data(row, field.fields))
          end
        else
          if value.is_a? Array
            result << value&.take(5)
          else
            result << value
          end
        end
      end
      result
    end
  end
end
