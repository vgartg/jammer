module Recoverable
  extend ActiveSupport::Concern
  included do
    before_update :clear_reset_password_token, if: :password_digest_changed?
    before_update :clear_remember_token_digest, if: :password_digest_changed?

    def set_password_reset_token
      token = SecureRandom.urlsafe_base64(32)
      update_columns(
        password_reset_token: digest(token),
        password_reset_token_sent_at: Time.current
      )
      token
    end

    def clear_reset_password_token
      self.password_reset_token = nil
      self.password_reset_token_sent_at = nil
    end

    def clear_remember_token_digest
      self.remember_token_digest = nil
    end

    def password_reset_period_valid?
      password_reset_token_sent_at.present? && Time.current - password_reset_token_sent_at <= 60.minutes
    end
  end
end
