require "rails_helper"

describe DataSourceAdapters::PrestoAdapter, type: :model do
  let(:data_source) { FactoryBot.create(:data_source, adapter: "presto", host: "presto.example.com", port: 8080, dbname: "hive", user: "dmemo", password: nil) }
  let(:adapter) { DataSourceAdapters::PrestoAdapter.new(data_source) }
  let(:client) { instance_double(Trino::Client::Client) }

  before do
    allow(Trino::Client).to receive(:new).and_return(client)
  end

  describe "connection config" do
    it "uses presto model version" do
      allow(client).to receive(:run).and_return([[], []])
      adapter.fetch_table_names
      expect(Trino::Client).to have_received(:new).with(catalog: "hive", server: "presto.example.com:8080", user: "dmemo", model_version: 316)
    end
  end
end
