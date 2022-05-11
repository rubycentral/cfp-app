class CreateWebsiteMetaData < ActiveRecord::Migration[6.1]
  def change
    create_table :website_meta_data do |t|
      t.string :title
      t.string :author
      t.text :description
      t.belongs_to :website, foreign_key: true

      t.timestamps
    end
  end
end
