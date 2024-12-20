class EditUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :real_name
      t.string :birthday
      t.string :location # -> as country, city
      t.string :phone_number
      t.string :status # -> as description
    end
  end
end
