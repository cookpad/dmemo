require "rails_helper"

describe SynchronizeDataSources do
  let!(:data_source) { FactoryBot.create(:data_source, name: "dmemo", description: "") }
  let(:batch) { SynchronizeDataSources }

  describe ".run" do
    it "synchronize data_source" do
      expect(DatabaseMemo.count).to eq(0)
      expect(TableMemoRawDataset.count).to eq(0)

      batch.run

      database_memo = data_source.database_memo
      expect(database_memo.name).to eq("dmemo")

      schema_memo = database_memo.schema_memos.take!
      expect(schema_memo.name).to eq("public")

      table_memos = schema_memo.table_memos
      expect(table_memos.find_by!(name: "data_sources")).to be_present

      dataset = table_memos.find_by!(name: "data_sources").raw_dataset
      expect(dataset.count).to eq(1)
      expect(dataset.columns.map(&:name)).to match_array(%w(id name description adapter host port dbname user password encoding pool created_at updated_at))
      expect(dataset.rows.take.row[1..7]).to match_array(["dmemo", "", data_source.adapter, "localhost", "5432", data_source.dbname, data_source.user])
    end

    context "with invalid connection param" do
      before do
        data_source.update!(port: 5439)
      end

      it "fails data_sources sync" do
        expect{ batch.run }.to raise_error(DataSource::ConnectionBad)

        expect(data_source.database_memo).to be_present
        expect(SchemaMemo.count).to eq(0)
        expect(TableMemoRawDataset.count).to eq(0)
      end
    end
  end
end
