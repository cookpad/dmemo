module RequestSpecHelper
  def self.last_response
    @response
  end

  def self.last_response=(response)
    @response = response
  end

  def set_rack_session(hash)
    data = ::RackSessionAccess.encode(hash)
    put RackSessionAccess.path, params: { data: data }
  end

  def login!(user: nil, admin: false)
    user ||= FactoryGirl.create(:user, admin: admin)
    set_rack_session(user_id: user.id)
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
