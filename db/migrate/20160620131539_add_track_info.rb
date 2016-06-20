class AddTrackInfo < ActiveRecord::Migration
  def change
    change_table :tracks do |t|
      t.string :description, limit: 250
      t.text :guidelines
    end
  end
end
