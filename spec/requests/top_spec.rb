require "rails_helper"

describe :top, type: :request do
  let(:data_source) { FactoryBot.create(:data_source) }
  before do
    login!
    DatabaseMemo.import_data_source!(data_source.id)
  end

  describe "#show" do
    it "shows top page" do
      get root_path
      expect(page).to have_content("DatabaseMEMO")
      expect(page).to have_selector("a[href='/databases/dmemo']")
    end
  end
end
