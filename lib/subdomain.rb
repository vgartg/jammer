class Subdomain
  def self.matches?(request)
    subdomain = extract_subdomain(request)
    subdomain.present? && subdomain != "www"
  end

  def self.extract_subdomain(request)
    Rails.env == "production" ? request.subdomain : request.host.split(".").first
  end

  def self.delete_subdomain(request)
    Rails.env == "production" ? request.domain + request.path : request.host.split('.').last + ':' + request.port.to_s + request.path
  end
end