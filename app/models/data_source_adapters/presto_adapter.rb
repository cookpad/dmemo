require 'presto-client'

module DataSourceAdapters
  class PrestoAdapter < StandardAdapter
    DataSourceAdapters.register_adapter(self, 'presto')

    def fetch_table_names
      schemas = run_query('show schemas')[1].flatten

      schemas.flat_map do |schema|
        run_query("show tables from #{schema}")[1].flatten.map { |table| [schema, table] }
      end
    end

    def fetch_columns(table)
      columns = run_query("show columns from #{table.full_table_name}")

      columns[1].map do |column| # e.g. ["updated_at", "timestamp", "", ""]
        Column.new(column[0], column[1], '', true);
      end
    end

    def reset!
      @client = nil
    end

    private

    def client
      @client ||= Presto::Client.new(connection_config)
    end

    def connection_config
      {
        catalog: @data_source.dbname,
        server: "#{@data_source.host}:#{@data_source.port}",
        user: @data_source.user,
        password: @data_source.password.presence,
      }.compact
    end

    def run_query(query)
      Rails.logger.info "Run Query: #{query}"
      client.run(query)
    rescue Presto::Client::PrestoError => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
