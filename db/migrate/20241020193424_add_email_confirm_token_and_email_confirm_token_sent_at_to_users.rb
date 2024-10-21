class AddEmailConfirmTokenAndEmailConfirmTokenSentAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_confirm_token, :string
    add_column :users, :email_confirm_token_sent_at, :datetime
  end
end
