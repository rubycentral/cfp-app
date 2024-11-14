class CreateTableWebsiteFonts < ActiveRecord::Migration[6.1]
  def change
    create_table :website_fonts do |t|
      t.string :name
      t.boolean :primary
      t.boolean :secondary
      t.belongs_to :website

      t.timestamps
    end
  end
end
