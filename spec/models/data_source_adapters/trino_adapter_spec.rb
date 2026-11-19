require "rails_helper"

describe DataSourceAdapters::TrinoAdapter, type: :model do
  let(:data_source) { FactoryBot.create(:data_source, adapter: "trino", host: "trino.example.com", port: 8080, dbname: "hive", user: "dmemo", password: nil) }
  let(:adapter) { DataSourceAdapters::TrinoAdapter.new(data_source) }
  let(:table) { DataSourceTable.new(data_source, 'public', 'keywords') }
  let(:client) { instance_double(Trino::Client::Client) }

  before do
    allow(Trino::Client).to receive(:new).and_return(client)
  end

  describe "#fetch_table_names" do
    it "return table names" do
      allow(client).to receive(:run).with('show schemas').and_return([[], [["public"], ["information_schema"]]])
      allow(client).to receive(:run).with('show tables from "public"').and_return([[], [["keywords"], ["users"]]])
      allow(client).to receive(:run).with('show tables from "information_schema"').and_return([[], [["tables"]]])

      expect(adapter.fetch_table_names).to eq [%w[public keywords], %w[public users], %w[information_schema tables]]
    end
  end

  describe "#fetch_columns" do
    it "return columns" do
      allow(client).to receive(:run).with('show columns from "public"."keywords"').and_return([[], [
        ["id", "bigint", "", ""],
        ["updated_at", "timestamp(3)", "", ""],
      ],])

      columns = adapter.fetch_columns(table)
      expect(columns.map(&:name)).to eq %w(id updated_at)
      expect(columns.map(&:sql_type)).to eq %w(bigint timestamp(3))
    end

    context "with query error" do
      it "raises error" do
        allow(client).to receive(:run).and_raise(Trino::Client::TrinoHttpError.new(500, "error"))

        expect { adapter.fetch_columns(table) }.to raise_error(DataSource::ConnectionBad)
      end
    end
  end

  describe "connection config" do
    before do
      allow(client).to receive(:run).and_return([[], []])
    end

    it "does not use ssl without password" do
      adapter.fetch_table_names
      expect(Trino::Client).to have_received(:new).with(catalog: "hive", server: "trino.example.com:8080", user: "dmemo")
    end

    it "uses ssl with password" do
      data_source.update!(password: "secret")
      adapter.fetch_table_names
      expect(Trino::Client).to have_received(:new).with(catalog: "hive", server: "trino.example.com:8080", user: "dmemo", password: "secret", ssl: true)
    end
  end
end
