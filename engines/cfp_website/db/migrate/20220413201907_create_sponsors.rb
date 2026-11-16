class CreateSponsors < ActiveRecord::Migration[6.1]
  def change
    create_table :sponsors do |t|
      t.belongs_to :event, foreign_key: true

      t.string :name
      t.string :tier
      t.boolean :published
      t.string :url
      t.string :other_title

      t.timestamps
    end
  end
end
