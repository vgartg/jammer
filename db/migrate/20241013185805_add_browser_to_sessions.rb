class AddBrowserToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :browser, :string
  end
end
