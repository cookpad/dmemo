require "rails_helper"

describe :top, type: :request do
  before do
    FactoryBot.create(:data_source)
    SynchronizeDataSources.run
    login!
  end

  describe "#show" do
    it "shows top page" do
      get root_path
      expect(page).to have_content("DatabaseMEMO")
      expect(page).to have_selector("a[href='/databases/dmemo']")
    end
  end
end
