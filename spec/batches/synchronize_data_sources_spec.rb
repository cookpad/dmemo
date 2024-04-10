require "rails_helper"

describe SynchronizeDataSources do
  let(:batch) { SynchronizeDataSources }

  describe ".run" do
    let!(:data_source) { FactoryBot.create(:data_source, name: "dmemo", description: "") }

    it "synchronize data_source" do
      expect(DatabaseMemo.count).to eq(0)

      batch.run

      database_memo = data_source.database_memo
      expect(database_memo.name).to eq("dmemo")

      schema_memo = database_memo.schema_memos.take!
      expect(schema_memo.name).to eq("public")

      table_memos = schema_memo.table_memos
      expect(table_memos.find_by!(name: "data_sources")).to be_present

      column_memos = table_memos.find_by!(name: "data_sources").column_memos
      expect(column_memos).to be_present
    end

    context "with invalid connection param" do
      before do
        data_source.update!(port: 5439)
      end

      it "fails data_sources sync" do
        expect { batch.run }.to raise_error(DataSource::ConnectionBad)

        expect(data_source.database_memo).to be_present
        expect(SchemaMemo.count).to eq(0)
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
      end
    end
  end
end
