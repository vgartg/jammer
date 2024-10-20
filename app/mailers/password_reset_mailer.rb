class PasswordResetMailer < ActionMailer::Base
  def reset_email
    @user = params[:user]
    mail to: @user.email, subject: "Reset password | Jammer"
  end
end