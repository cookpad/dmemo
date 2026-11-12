require 'trino-client'

module DataSourceAdapters
  class TrinoAdapter < StandardAdapter
    DataSourceAdapters.register_adapter(self, 'trino')

    def fetch_table_names
      schemas = run_query('show schemas')[1].flatten

      schemas.flat_map do |schema|
        run_query("show tables from #{quote_identifier(schema)}")[1].flatten.map { |table| [schema, table] }
      end
    end

    def fetch_columns(table)
      columns = run_query("show columns from #{quote_identifier(table.schema_name)}.#{quote_identifier(table.table_name)}")

      columns[1].map do |column| # e.g. ["updated_at", "timestamp(3)", "", ""]
        Column.new(column[0], column[1], '', true)
      end
    end

    def reset!
      @client = nil
    end

    private

    def client
      @client ||= Trino::Client.new(connection_config)
    end

    def connection_config
      password = @data_source.password.presence
      {
        catalog: @data_source.dbname,
        server: "#{@data_source.host}:#{@data_source.port}",
        user: @data_source.user,
        password: password,
        # trino-client requires https when password is given
        ssl: password ? true : nil,
      }.compact
    end

    def quote_identifier(name)
      %("#{name.gsub('"', '""')}")
    end

    def run_query(query)
      Rails.logger.info "Run Query: #{query}"
      client.run(query)
    rescue Trino::Client::TrinoError, Faraday::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
