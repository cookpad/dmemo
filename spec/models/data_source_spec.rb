require "rails_helper"

describe DataSource, type: :model do
  let(:data_source) { FactoryGirl.create(:data_source) }

  describe "#data_source_table" do
    it "return data source table" do
      expect(data_source.data_source_table("public", "data_sources")).to be_present
      expect(data_source.data_source_table("public", "data_sources").columns.map(&:name)).to match_array(%w(
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
