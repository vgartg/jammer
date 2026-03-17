class CreateJamCriterionPicks < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_criterion_picks do |t|
      t.references :jam, null: false, foreign_key: true
      t.references :jam_criterion, null: false, foreign_key: { to_table: :jam_criteria }
      t.references :voter, null: false, foreign_key: { to_table: :users }
      t.references :game, null: false, foreign_key: true
      t.string :channel, null: false, default: "jury"

      t.timestamps
    end

    add_index :jam_criterion_picks,
              [:jam_id, :jam_criterion_id, :voter_id, :channel],
              unique: true,
              name: "idx_unique_pick_per_criterion"
  end
end