module Confirmable
  extend ActiveSupport::Concern
  included do
    before_update :clear_email_confirm_token, if: :email_confirmed_changed?
    def set_email_confirm_token
      token = generate_token
      update_column(:email_confirm_token, digest(token))
      update_column(:email_confirm_token_sent_at, Time.current)
      return token
    end

    def generate_token(length = 6)
      charset = Array('0'..'9') + Array('a'..'z') + Array('A'..'Z')
      Array.new(length) { charset.sample }.join
    end

    def clear_email_confirm_token
      self.email_confirm_token = nil
      self.email_confirm_token_sent_at = nil
    end

    def email_confirm_period_valid?
      email_confirm_token_sent_at.present? && Time.current - email_confirm_token_sent_at <= 60.minutes
    end
  end
end