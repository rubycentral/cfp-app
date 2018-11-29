class CreateTaggings < ActiveRecord::Migration[5.1]
  def change
    create_table :taggings do |t|
      t.references :proposal, index: true
      t.string :tag
      t.boolean :internal, default: false

      t.timestamps null: true
    end
  end
end
