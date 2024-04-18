require "rails_helper"

describe AutolinkKeyword, type: :model do
  describe ".links" do
    let(:database_memo) { FactoryBot.create(:database_memo, name: "db") }
    let(:schema_memo) { FactoryBot.create(:schema_memo, database_memo:, name: "myapp") }
    before do
      FactoryBot.create(:table_memo, schema_memo:, name: "books")
      FactoryBot.create(:keyword, name: "difficult-word", description: "Difficult!")
    end

    it "returns links to table" do
      expect(AutolinkKeyword.links).to eq(
        "books" => "/databases/db/myapp/books",
        "myapp.books" => "/databases/db/myapp/books",
        "difficult-word" => "/keywords/difficult-word",
      )
    end

    context "after table_memos created" do
      it "clears links" do
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
        )
        memo = FactoryBot.create(:table_memo, schema_memo:, name: "blogs")
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "blogs" => "/databases/db/myapp/blogs",
          "myapp.blogs" => "/databases/db/myapp/blogs",
          "difficult-word" => "/keywords/difficult-word",
        )
        memo.update!(name: "alphabets")
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "alphabets" => "/databases/db/myapp/alphabets",
          "myapp.alphabets" => "/databases/db/myapp/alphabets",
          "difficult-word" => "/keywords/difficult-word",
        )
        memo.destroy!
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
        )
      end
    end

    context "after keyword created" do
      it "clears links" do
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
        )
        keyword = FactoryBot.create(:keyword, name: "easy-word", description: "Easy!")
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
          "easy-word" => "/keywords/easy-word",
        )
        keyword.update!(name: "easy")
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
          "easy" => "/keywords/easy",
        )
        keyword.destroy!
        expect(AutolinkKeyword.links).to eq(
          "books" => "/databases/db/myapp/books",
          "myapp.books" => "/databases/db/myapp/books",
          "difficult-word" => "/keywords/difficult-word",
        )
      end
    end
  end
end
