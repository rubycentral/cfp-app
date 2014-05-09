class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :proposal, index: true
      t.string :tag
      t.boolean :internal, default: false

      t.timestamps
    end
  end
end
