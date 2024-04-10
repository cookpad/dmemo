require "rails_helper"

describe DataSourceAdapters::StandardAdapter, type: :model do
  let(:data_source) { FactoryBot.create(:data_source) }
  let(:adapter) { DataSourceAdapters::StandardAdapter.new(data_source) }
  let(:table) { DataSourceTable.new(data_source, 'public', 'keywords') }

  describe "#source_base_class" do
    it "return source base class" do
      expect(adapter.source_base_class).to eq(DataSourceAdapters::DynamicTable::Dmemo_Base)
    end
  end

  describe "#fetch_columns" do
    it "return columns" do
      expect(adapter.fetch_columns(table).first).to be_a DataSourceAdapters::Column
    end

    context "with invalid connection param" do
      before do
        data_source.update!(port: 5439)
      end

      it "raises error" do
        expect { adapter.fetch_columns(table) }.to raise_error(DataSource::ConnectionBad)
      end
    end
  end
end
