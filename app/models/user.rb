class User
  attr_reader :uid, :info, :provider

  def self.from_session(user_info)
    User.new(user_info)
  end

  def initialize(user_info)
    @uid = user_info["uid"]
    @info = user_info["info"]
    @provider = user_info["provider"]
  end

  def name
    info["name"]
  end

  def image_url
    info["image"]
  end
end
