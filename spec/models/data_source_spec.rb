require "rails_helper"

describe DataSource, type: :model do
  let(:data_source) { FactoryBot.create(:data_source) }

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
    it "returns table_names" do
      expect(data_source.data_source_tables.map(&:table_name)).to include("data_sources")
    end

    context "with invalid connection param" do
      before do
        data_source.update!(port: 5439)
      end

      it "raises error" do
        expect { data_source.data_source_tables }.to raise_error(DataSource::ConnectionBad)
      end
    end

    context "with ignored pattern" do
      it "ignores specified table" do
        FactoryBot.create(:ignored_table, data_source:, pattern: "data_sources")
        expect(data_source.data_source_tables.map(&:table_name)).not_to include("data_sources")
      end

      it "ignores specified schema" do
        FactoryBot.create(:ignored_table, data_source:, pattern: "public")
        expect(data_source.data_source_tables.map(&:table_name)).to eq []
      end
    end
  end

  describe "#data_source_tables" do
    it "returns data source tables" do
      expect(data_source.data_source_tables.size).to be > 0
    end
  end

  describe "validation" do
    it "rejects creating with a deprecated adapter" do
      data_source = FactoryBot.build(:data_source, adapter: "presto")
      expect(data_source).not_to be_valid
      expect(data_source.errors[:adapter]).to be_present
    end

    it "rejects changing to a deprecated adapter" do
      data_source.adapter = "presto"
      expect(data_source).not_to be_valid
    end
  end

  context "with deprecated adapter" do
    let(:data_source) { FactoryBot.create(:data_source, :deprecated_adapter) }

    it "is deprecated" do
      expect(data_source).to be_deprecated_adapter
    end

    it "raises AdapterDeprecated when fetching data" do
      expect { data_source.data_source_tables }.to raise_error(DataSource::AdapterDeprecated)
    end

    it "allows updating other attributes" do
      expect(data_source.update(description: "legacy")).to eq(true)
    end
  end
end
