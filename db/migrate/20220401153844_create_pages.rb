class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.belongs_to :website, foreign_key: true
      t.string :name
      t.string :slug
      t.text :body

      t.timestamps
    end
  end
end
