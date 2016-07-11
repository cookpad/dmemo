require "rails_helper"

describe Keyword, type: :model do
  describe ".links" do
    let(:database_memo) { FactoryGirl.create(:database_memo, name: "db") }
    let(:schema_memo) { FactoryGirl.create(:schema_memo, database_memo: database_memo, name: "myapp") }
    before do
      FactoryGirl.create(:table_memo, schema_memo: schema_memo, name: "books")
    end

    it "returns links to table" do
      expect(Keyword.links).to eq(
        "books" => "/databases/db/myapp/books",
        "myapp.books" => "/databases/db/myapp/books",
      )
    end

    context "after table_memos created" do
      it "clears links" do
        expect(Keyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
        )
        memo = FactoryGirl.create(:table_memo, schema_memo: schema_memo, name: "blogs")
        expect(Keyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "blogs" => "/databases/db/myapp/blogs",
          "myapp.blogs" => "/databases/db/myapp/blogs",
        )
        memo.update!(name: "alphabets")
        expect(Keyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "alphabets" => "/databases/db/myapp/alphabets",
          "myapp.alphabets" => "/databases/db/myapp/alphabets",
        )
        memo.destroy!
        expect(Keyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
        )
      end
    end
  end
end
