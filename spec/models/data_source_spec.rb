require "rails_helper"

describe DataSource, type: :model do
  describe "#source_tables" do
    let(:data_source) { FactoryGirl.create(:data_source) }

    it "returns data source table classes" do
      expect(data_source.source_tables.size).to be > 0
    end
  end
end
