class ConvertGameDescriptionToRichText < ActiveRecord::Migration[8.0]
  def up
    change_column_null :games, :description, true

    select_all("SELECT id, description FROM games WHERE description IS NOT NULL AND description != ''").each do |row|
      body = ActionController::Base.helpers.simple_format(row["description"].to_s)
      ActionText::RichText.create!(
        name: "description",
        body: body,
        record_type: "Game",
        record_id: row["id"]
      )
    end
  end

  def down
    ActionText::RichText.where(name: "description", record_type: "Game").delete_all
    change_column_null :games, :description, false
  end
end
