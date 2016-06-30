class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :proposal, index: true
      t.references :user, index: true
      t.integer :score

      t.timestamps
    end
  end
end
