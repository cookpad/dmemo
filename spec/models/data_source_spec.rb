require "rails_helper"

describe DataSource, type: :model do
  let(:data_source) { FactoryGirl.create(:data_source) }

  describe "#source_table_class_name" do
    it { expect(data_source.source_table_class_name("Base")).to eq("DmemoTest_Base") }
  end

  describe "#source_base_class" do
    it "return source base class" do
      expect(data_source.source_base_class).to eq(DataSource::DynamicTable::DmemoTest_Base)
      expect(data_source.source_base_class).to eq(DataSource::DynamicTable::DmemoTest_Base)
    end
  end

  describe "#source_table_class" do
    it "return data source class" do
      expect(data_source.source_table_class("data_sources")).to eq(DataSource::DynamicTable::DmemoTest_DataSource)
      expect(data_source.source_table_class("data_sources")).to eq(DataSource::DynamicTable::DmemoTest_DataSource)
      expect(DataSource::DynamicTable::DmemoTest_DataSource.columns.map(&:name)).to match_array(%w(
        id name description adapter host port dbname user password created_at updated_at
      ))
    end
  end

  describe "#source_table_classes" do
    it "returns data source table classes" do
      expect(data_source.source_table_classes.size).to be > 0
    end
  end
end
