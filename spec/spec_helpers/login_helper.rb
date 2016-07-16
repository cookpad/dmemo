module LoginHelper
  def set_rack_session(hash)
    data = ::RackSessionAccess.encode(hash)
    put RackSessionAccess.path, data: data
  end

  def login!(admin: false)
    user = FactoryGirl.create(:user, admin: admin)
    set_rack_session(user_id: user.id)
  end
end

RSpec.configure do |c|
  c.include LoginHelper, type: :request
end
