require "rails_helper"

describe SynchronizeDataSources do
  let(:batch) { SynchronizeDataSources }

  describe ".run" do
    let!(:data_source) { FactoryBot.create(:data_source, name: "dmemo", description: "") }

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

      column_memos = table_memos.find_by!(name: "data_sources").column_memos
      expect(column_memos).to be_present

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
        expect { batch.run }.to raise_error(DataSource::ConnectionBad)

        expect(data_source.database_memo).to be_present
        expect(SchemaMemo.count).to eq(0)
        expect(TableMemoRawDataset.count).to eq(0)
      end
    end
  end

  describe ".import_data_source" do
    let(:data_source) { FactoryBot.create(:data_source) }

    describe ".import_data_source!" do
      it "synchronize data source" do
        FactoryBot.create(:keyword, name: "tempura")

        expect(DatabaseMemo.count).to eq(0)
        batch.import_data_source!(data_source)

        database_memo = DatabaseMemo.take
        expect(database_memo.name).to eq(data_source.name)

        keywords_table = TableMemo.find_by(name: "keywords")
        expect(keywords_table.raw_dataset.count).to eq(1)
        expect(keywords_table.raw_dataset.rows.size).to eq(1)

        FactoryBot.create(:keyword, name: "sushi")

        batch.import_data_source!(data_source)
        expect(keywords_table.reload.raw_dataset.count).to eq(2)
        expect(keywords_table.raw_dataset.rows.size).to eq(2)
      end

      context "when columns doesn't changed" do
        before do
          stub_const("SynchronizeDataSources::DEFAULT_FETCH_ROWS_LIMIT", 4)
          4.times { |i| FactoryBot.create(:keyword, name: "sushi #{i}") }
          batch.import_data_source!(data_source)
        end

        it "skip update raw_dataset.rows" do
          keywords_table = TableMemo.find_by(name: "keywords")
          expect(keywords_table.raw_dataset.count).to eq(4)
          before_row_ids = keywords_table.raw_dataset.rows.order(:id).pluck(:id)

          FactoryBot.create(:keyword, name: "tempura")
          batch.import_data_source!(data_source)
          keywords_table.reload
          after_row_ids = keywords_table.raw_dataset.rows.order(:id).pluck(:id)

          expect(keywords_table.raw_dataset.count).to eq(5)
          expect(after_row_ids).to eq(before_row_ids)
        end
      end
    end
  end
end
