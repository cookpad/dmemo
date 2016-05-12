Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV["GOOGLE_HOSTED_DOMAIN"].present?
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], hd: ENV["GOOGLE_HOSTED_DOMAIN"]
  else
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
  end
end
