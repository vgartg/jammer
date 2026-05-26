class PasswordResetMailer < ActionMailer::Base
  default from: 'jammer.website@internet.ru'

  def reset_email
    @user = params[:user]
    locale = params[:locale] || I18n.locale
    I18n.with_locale(locale) do
      mail to: @user.email, subject: t('mailers.password_reset.subject')
    end
  end
end
