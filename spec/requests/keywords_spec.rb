require "rails_helper"

describe :keywords, type: :request do
  before do
    login!
  end

  describe "#index" do
    before do
      FactoryGirl.create(:keyword, name: "sushi", description: "**delicious**")
      FactoryGirl.create(:keyword, name: "toast", description: "__rice__")
    end

    it "shows index" do
      get keywords_path
      expect(response).to render_template("keywords/index")

      # shows keyword links
      expect(page).to have_xpath("//a[text()='sushi']")
      expect(page).to have_xpath("//a[text()='toast']")

      # shows striped plain text description
      expect(page).to have_xpath("//td[text()='delicious']")
      expect(page).to have_xpath("//td[text()='rice']")
    end
  end

  describe "#show" do
    before do
      FactoryGirl.create(:keyword, name: "sushi", description: "**delicious**")
    end

    it "shows keyword detail" do
      get keyword_path("sushi")
      expect(response).to render_template("keywords/show")

      expect(page).to have_text("sushi")
      expect(page).to have_xpath("//strong[text()='delicious']")
    end
  end

  describe "#new" do
    it "shows new page" do
      get new_keyword_path
      expect(response).to render_template("keywords/new")
    end
  end

  describe "#create" do
    it "creates keyword" do
      post keywords_path, keyword: { name: "foo", description: "foo description" }
      keyword = Keyword.find_by!(name: "foo")
      expect(response).to redirect_to(keyword)
      expect(keyword.logs.count).to eq(1)
    end
  end

  describe "#edit" do
    let(:keyword) { FactoryGirl.create(:keyword, name: "sushi", description: "**delicious**") }

    it "shows edit form" do
      get edit_keyword_path(keyword)
      expect(response).to render_template("keywords/edit")
      expect(page).to have_text("sushi")
      expect(page).to have_text("delicious")
    end
  end

  describe "#update" do
    let(:keyword) { FactoryGirl.create(:keyword, name: "sushi", description: "sushi 1") }

    it "updates keyword" do
      expect(keyword.logs.count).to eq(0)
      patch keyword_path(keyword), keyword: { description: "sushi 2" }
      expect(response).to redirect_to(keyword)
      expect(keyword.reload.description).to eq("sushi 2")
      expect(keyword.logs.count).to eq(1)
    end
  end

  describe "#destroy" do
    let(:keyword) { FactoryGirl.create(:keyword, name: "sushi", description: "sushi 1") }

    it "destroys keyword" do
      delete keyword_path(keyword)
      expect(response).to redirect_to(keywords_path)
      expect(Keyword.count).to eq(0)
      expect(KeywordLog.count).to eq(0)
    end
  end
end
