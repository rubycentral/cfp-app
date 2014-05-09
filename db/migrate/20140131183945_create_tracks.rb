class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.text :name
      t.references :event, index: true

      t.timestamps
    end
  end
end
