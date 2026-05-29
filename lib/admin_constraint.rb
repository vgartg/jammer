class AdminConstraint
  def matches?(request)
    user_id = request.session[:current_user]
    return false unless user_id

    User.find_by(id: user_id)&.admin?
  end
end
