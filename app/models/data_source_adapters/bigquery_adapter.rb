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
      client =
        if config.credentials
          Google::Cloud::Bigquery.new(
            project_id: config.project_id,
            credentials: JSON.parse(config.credentials),
          )
        else
          Google::Cloud::Bigquery.new(project_id: config.project_id)
        end

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
  end
end
