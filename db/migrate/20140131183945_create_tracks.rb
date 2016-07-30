class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.references :event, index: true
      t.string :name
      t.string :description, limit: 250
      t.text :guidelines

      t.timestamps null: true
    end
  end
end
