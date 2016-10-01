require "rails_helper"

describe :sessions, type: :request do
  describe "#create" do
    let(:oauth) {
      { provider: "google_oauth2", uid: 1, info: { name: "foo", email: "foo@example.com", image: "foo.jpg" } }
    }
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(oauth)
    end

    it "creates user and session" do
      expect(User.count).to eq(0)

      get auth_google_oauth2_callback_path

      expect(response).to redirect_to(root_path)
      expect(User.find(session[:user_id]).name).to eq(oauth[:info][:name])
    end

    context "with existing user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        oauth[:uid] = user.uid
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(oauth)
      end

      it "creates only session" do
        expect(User.count).to eq(1)

        get auth_google_oauth2_callback_path

        expect(response).to redirect_to(root_path)
        expect(User.find(session[:user_id]).name).to eq(oauth[:info][:name])
        expect(User.count).to eq(1)
      end
    end
  end

  describe "#destroy" do
    before do
      login!
    end

    it "destroys session" do
      expect(session[:user_id]).not_to eq(nil)
      delete logout_path
      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(nil)
    end
  end
end
