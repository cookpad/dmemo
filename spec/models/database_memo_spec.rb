require "rails_helper"

describe DatabaseMemo, type: :model do
  let(:data_source) { FactoryBot.create(:data_source) }

  describe ".import_data_source!" do
    it "synchronize data source" do
      FactoryBot.create(:keyword, name: "tempura")

      expect(DatabaseMemo.count).to eq(0)
      DatabaseMemo.import_data_source!(data_source.id)

      database_memo = DatabaseMemo.take
      expect(database_memo.name).to eq(data_source.name)

      keywords_table = TableMemo.find_by(name: "keywords")
      expect(keywords_table.raw_dataset.count).to eq(1)
      expect(keywords_table.raw_dataset.rows.size).to eq(1)

      FactoryBot.create(:keyword, name: "sushi")

      DatabaseMemo.import_data_source!(data_source.id)
      expect(keywords_table.reload.raw_dataset.count).to eq(2)
      expect(keywords_table.raw_dataset.rows.size).to eq(2)
    end

    context "when columns doesn't changed" do
      before do
        stub_const("DatabaseMemo::DEFAULT_FETCH_ROWS_LIMIT", 4)
        4.times{|i| FactoryBot.create(:keyword, name: "sushi #{i}") }
        DatabaseMemo.import_data_source!(data_source.id)
      end

      it "skip update raw_dataset.rows" do
        keywords_table = TableMemo.find_by(name: "keywords")
        expect(keywords_table.raw_dataset.count).to eq(4)
        before_row_ids = keywords_table.raw_dataset.rows.order(:id).pluck(:id)

        FactoryBot.create(:keyword, name: "tempura")
        DatabaseMemo.import_data_source!(data_source.id)
        keywords_table.reload
        after_row_ids = keywords_table.raw_dataset.rows.order(:id).pluck(:id)

        expect(keywords_table.raw_dataset.count).to eq(5)
        expect(after_row_ids).to eq(before_row_ids)
      end
    end
  end
end
