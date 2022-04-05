class CreateWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :websites do |t|
      t.belongs_to :event
      t.string :phase
      t.string :theme, default: 'default'

      t.timestamps
    end
  end
end
