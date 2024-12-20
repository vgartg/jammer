class Subdomain
  def self.matches?(request)
    subdomain = extract_subdomain(request)
    subdomain.present? && subdomain != 'www'
  end

  def self.extract_subdomain(request)
    Rails.env == 'production' ? request.subdomain : request.host.split('.').first
  end
end
