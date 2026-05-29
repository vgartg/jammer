class AdminConstraint
  def matches?(request)
    user_id = request.session[:current_user]
    return false unless user_id

    user = User.find_by(id: user_id)
    return false unless user&.admin?

    browser = UserAgent.parse(request.user_agent).browser
    Session.where(user_id: user_id, ip_address: request.remote_ip, browser: browser).exists?
  end
end
