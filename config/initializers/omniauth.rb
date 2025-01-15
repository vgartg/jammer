# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
           scope: 'user:email'
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true