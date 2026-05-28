Rails.application.config.middleware.use OmniAuth::Builder do
  github_id     = Rails.env.development? ? ENV.fetch('GITHUB_CLIENT_ID_DEV', nil)     : ENV.fetch('GITHUB_CLIENT_ID', nil)
  github_secret = Rails.env.development? ? ENV.fetch('GITHUB_CLIENT_SECRET_DEV', nil) : ENV.fetch('GITHUB_CLIENT_SECRET', nil)

  provider :github, github_id, github_secret, scope: 'user:email'

  provider :google_oauth2,
           ENV.fetch('GOOGLE_CLIENT_ID', nil),
           ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
           {
             scope: 'email,profile',
             prompt: 'select_account'
           }
end

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
