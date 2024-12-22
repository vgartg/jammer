if defined?(Rails.root.to_s) && File.exist?("#{Rails.root}/config/version.yml")
  APP_VERSION = App::Version.load("#{Rails.root}/config/version.yml")
end
