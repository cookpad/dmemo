require "rails_helper"

describe Keyword, type: :model do
  describe ".links" do
    before do
      TableMemo.create!(name: "books", schema_memo_id: 0)
    end

    it { expect(Keyword.links).to eq("books" => "/keywords/books") }

    context "after table_memos created" do
      it "clears links" do
        expect(Keyword.links).to eq("books" => "/keywords/books")
        memo = TableMemo.create!(name: "blogs", schema_memo_id: 0)
        expect(Keyword.links).to eq(
          "blogs" => "/keywords/blogs",
          "books" => "/keywords/books",
        )
        memo.update!(name: "alphabets")
        expect(Keyword.links).to eq(
          "alphabets" => "/keywords/alphabets",
          "books" => "/keywords/books",
        )
        memo.destroy!
        expect(Keyword.links).to eq("books" => "/keywords/books")
      end
    end
  end
end
