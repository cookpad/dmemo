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
end
