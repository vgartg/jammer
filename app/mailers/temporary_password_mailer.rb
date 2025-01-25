class TemporaryPasswordMailer < ApplicationMailer
  def temporary_password_email(user, temp_password)
    @user = user
    @temp_password = temp_password
    mail(to: @user.email, subject: 'Ваш временный пароль для Jammer')
  end
end
