class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :proposal, index: true
      t.references :person, index: true
      t.integer :parent_id
      t.text :body
      t.string :type

      t.timestamps
    end
  end
end
