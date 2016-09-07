require "rails_helper"

describe DatabaseMemo, type: :model do
  let(:data_source) { FactoryGirl.create(:data_source) }

  describe ".import_data_source!" do
    it "synchronize data source" do
      FactoryGirl.create(:keyword, name: "tempura")

      expect(DatabaseMemo.count).to eq(0)
      DatabaseMemo.import_data_source!(data_source.id)

      database_memo = DatabaseMemo.take
      expect(database_memo.name).to eq(data_source.name)

      keywords_table = TableMemo.find_by(name: "keywords")
      expect(keywords_table.raw_dataset.count).to eq(1)
      expect(keywords_table.raw_dataset.rows.size).to eq(1)

      FactoryGirl.create(:keyword, name: "sushi")

      DatabaseMemo.import_data_source!(data_source.id)
      expect(keywords_table.reload.raw_dataset.count).to eq(2)
      expect(keywords_table.raw_dataset.rows.size).to eq(2)
    end
  end
end
