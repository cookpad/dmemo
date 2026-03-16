module RequestSpecHelper
  def self.last_response
    @response
  end

  def self.last_response=(response)
    @response = response
  end

  def login!(user: nil, admin: false)
    user ||= FactoryBot.create(:user, admin:)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { name: user.name, email: user.email, image: user.image_url },
    )
    get auth_google_oauth2_callback_path
  end

  def page
    Capybara.string(response.body)
  end

  def save_and_open_page
    RequestSpecHelper.last_response = response
    current_session = Capybara.current_session
    def current_session.body
      RequestSpecHelper.last_response.body
    end
    current_session.save_and_open_page
  end
end

RSpec.configure do |c|
  c.include RequestSpecHelper, type: :request

  c.before(:each) do
    Capybara.asset_host = "http://localhost:3000"
  end
end
