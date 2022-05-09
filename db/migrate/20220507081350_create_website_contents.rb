class CreateWebsiteContents < ActiveRecord::Migration[6.1]
  def change
    create_table :website_contents do |t|
      t.text :html
      t.string :placement, default: "head", null: false
      t.string :name
      t.belongs_to :website

      t.timestamps
    end
  end
end
