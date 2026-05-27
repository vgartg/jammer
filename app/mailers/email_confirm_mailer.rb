class EmailConfirmMailer < ActionMailer::Base
  default from: 'jammer.website@internet.ru'

  def email_confirm
    @user = params[:user]
    @token = params[:token]
    locale = params[:locale] || I18n.locale
    I18n.with_locale(locale) do
      mail to: @user.email, subject: t('mailers.email_confirm.subject')
    end
  end
end
