require "rails_helper"

describe DataSourceAdapters::BigqueryAdapter, type: :model do
  let(:data_source) { FactoryBot.create(:data_source, :bigquery_adapter) }
  let(:adapter) { DataSourceAdapters::BigqueryAdapter.new(data_source) }
  let(:table) { DataSourceTable.new(data_source, 'public', 'keywords') }

  describe "fetch_table_names" do
    it "return table names" do
      allow(adapter).to receive(:fetch_all_table_ids)
                          .and_return(%w(partitioned_table20180801 partitioned_table20180802))
      allow(adapter).to receive_message_chain(:bq_dataset, :dataset_id)
                          .and_return('sample')

      expect(adapter.fetch_table_names).to eq [%w[sample partitioned_table]]
    end
  end

  let(:dummy_fields) {
    field = Struct.new(:name, :mode, :type, :fields)
    [
      field.new('col1', 'NULLABLE', 'INTEGER', []),
      field.new('col2', 'REPEATED', 'RECORD', [
        field.new('subcol1', 'NULLABLE', 'INTEGER', []),
        field.new('subcol2', 'NULLABLE', 'INTEGER', []),
      ]),
    ]
  }

  describe "#fetch_columns" do
    it "return columns" do
      moc = double('bq_table_moc')
      allow(adapter).to receive(:bq_table).and_return(moc)
      allow(moc).to receive(:fields).and_return(dummy_fields)

      expect(adapter.fetch_columns(table).map(&:name)).to eq %w(col1 col2 col2.subcol1 col2.subcol2)
      expect(adapter.fetch_columns(table).map(&:sql_type)).to eq %w(INTEGER RECORD[] INTEGER INTEGER)
    end
  end
end
