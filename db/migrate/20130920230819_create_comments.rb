class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :proposal, index: true
      t.references :user, index: true
      t.integer :parent_id
      t.text :body
      t.string :type

      t.timestamps null: true
    end
  end
end
