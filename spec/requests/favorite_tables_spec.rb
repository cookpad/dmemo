require "rails_helper"

describe :favorite_tables, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  let(:table_memo) { FactoryGirl.create(:table_memo) }
  before do
    login!(user: user)
  end

  describe "#create" do
    it "creates favorite table" do
      post table_memo_favorite_table_path(table_memo), params: { format: :json }
      expect(response).to render_template("favorite_tables/create")
      favorite_table = FavoriteTable.find(JSON.parse(response.body)["id"])
      expect(favorite_table.user).to eq(user)
      expect(favorite_table.table_memo).to eq(table_memo)
    end
  end

  describe "#destroy" do
    before do
      FactoryGirl.create(:favorite_table, user: user, table_memo: table_memo)
    end

    it "destroys favorite table" do
      delete table_memo_favorite_table_path(table_memo), params: { format: :json }
      expect(response).to render_template("favorite_tables/destroy")
      expect(FavoriteTable.count).to eq(0)
    end
  end
end
