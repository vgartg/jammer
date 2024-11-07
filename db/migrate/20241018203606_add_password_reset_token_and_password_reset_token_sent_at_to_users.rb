class AddPasswordResetTokenAndPasswordResetTokenSentAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_token_sent_at, :datetime
  end
end
