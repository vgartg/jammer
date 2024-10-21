class EmailConfirmMailer < ActionMailer::Base
  def email_confirm
    @user = params[:user]
    @token = params[:token]
    mail to: @user.email, subject: "Confirm email | Jammer"
  end
end