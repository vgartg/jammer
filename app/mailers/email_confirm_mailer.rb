class EmailConfirmMailer < ActionMailer::Base
  default from: "jammer.website@internet.ru"
  def email_confirm
    @user = params[:user]
    @token = params[:token]
    mail to: @user.email, subject: "Confirm email | Jammer"
  end
end