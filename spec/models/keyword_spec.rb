require "rails_helper"

describe Keyword, type: :model do
  describe ".links" do
    before do
      SchemaMemo.create!(id: 1, name: "myapp", database_memo_id: 0)
      TableMemo.create!(id: 97, name: "books", schema_memo_id: 1)
    end

    it { expect(Keyword.links).to eq("books" => "/keywords/books", "myapp.books" => "/tables/97") }

    context "after table_memos created" do
      it "clears links" do
        expect(Keyword.links).to eq("books" => "/keywords/books", "myapp.books" => "/tables/97")
        memo = TableMemo.create!(id: 98, name: "blogs", schema_memo_id: 1)
        expect(Keyword.links).to eq(
          "blogs" => "/keywords/blogs",
          "myapp.blogs" => "/tables/98",
          "books" => "/keywords/books",
          "myapp.books" => "/tables/97",
        )
        memo.update!(name: "alphabets")
        expect(Keyword.links).to eq(
          "alphabets" => "/keywords/alphabets",
          "myapp.alphabets" => "/tables/98",
          "books" => "/keywords/books",
          "myapp.books" => "/tables/97",
        )
        memo.destroy!
        expect(Keyword.links).to eq("books" => "/keywords/books", "myapp.books" => "/tables/97")
      end
    end
  end
end
