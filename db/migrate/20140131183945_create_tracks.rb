class CreateTracks < ActiveRecord::Migration[5.1]
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
