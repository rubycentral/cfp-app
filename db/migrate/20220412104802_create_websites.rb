class CreateWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :websites do |t|
      t.belongs_to :event, foreign_key: true

      t.timestamps
    end
  end
end
