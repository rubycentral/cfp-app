class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.belongs_to :website, foreign_key: true
      t.text :published_body
      t.text :unpublished_body

      t.timestamps
    end
  end
end
