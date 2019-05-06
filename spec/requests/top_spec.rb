require "rails_helper"

describe :top, type: :request do
  before do
    FactoryBot.create(:data_source)
    SynchronizeDataSources.run
  end

  describe "#show" do
    context "with signed-in" do
      before { login! }
      it "shows top page" do
        get root_path
        expect(page).to have_content("DatabaseMEMO")
        expect(page).to have_selector("a[href='/databases/dmemo']")
      end
    end

    context "with not signed-in" do
      context 'with disallowing anonymous to read' do
        it "redirects" do
          get root_path
          expect(response.location).to match('http://www.example.com/auth/google_oauth2.*?')
        end
      end

      context 'with allowing anonymous to read' do
        before { Rails.application.config.allow_anonymous_to_read = true }
        it "shows top page" do
          get root_path
          expect(page).to have_content("DatabaseMEMO")
          expect(page).to have_selector("a[href='/databases/dmemo']")
        end
      end
    end
  end
end
