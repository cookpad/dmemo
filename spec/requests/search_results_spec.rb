require "rails_helper"

describe :search_results, type: :request do
  describe "#show" do
    let!(:table_memo) { FactoryGirl.create(:table_memo, name: "foo_bar_table") }
    let!(:column_memo) { FactoryGirl.create(:column_memo, name: "foo_bar_column") }
    before do
      login!
    end

    it "shows search result" do
      get search_results_path, params: { search_result: { keyword: "bar" } }
      expect(response).to render_template("search_results/show")
      expect(page).to have_text(table_memo.full_name)
      expect(page).to have_text(column_memo.full_name)
    end
  end
end
