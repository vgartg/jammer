class PasswordResetMailer < ActionMailer::Base
  default from: 'jammer.website@internet.ru'
  def reset_email
    @user = params[:user]
    mail to: @user.email, subject: 'Reset password | Jammer'
  end
end
