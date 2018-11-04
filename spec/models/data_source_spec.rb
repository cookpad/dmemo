require "rails_helper"

describe DataSource, type: :model do
  let(:data_source) { FactoryBot.create(:data_source) }

  describe "#source_base_class" do
    it "return source base class" do
      expect(data_source.source_base_class).to eq(DataSource::DynamicTable::Dmemo_Base)
    end
  end

  describe "#data_source_table" do
    it "return data source table" do
      table_names = data_source.source_table_names
      ds_table = data_source.data_source_table("public", "data_sources", table_names)
      expect(ds_table).to be_present
      expect(ds_table.columns.map(&:name)).to match_array(%w(
        id name description adapter host port dbname user password encoding pool created_at updated_at
      ))
    end
  end

  describe "#data_source_tables" do
    it "returns data source tables" do
      expect(data_source.data_source_tables.size).to be > 0
    end
  end
end
