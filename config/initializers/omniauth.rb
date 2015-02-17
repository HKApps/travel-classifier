Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOG_CLIENT_ID'], ENV['GOOG_CLIENT_SECRET'], {
    scope: [
      'calendar',
      'gmail.readonly',
      'userinfo.email'
    ],
    consent: 'prompt',
    access_type: 'offline'
  }
end
