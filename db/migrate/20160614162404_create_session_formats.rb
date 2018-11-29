class CreateSessionFormats < ActiveRecord::Migration[5.1]
  def change
    create_table :session_formats do |t|
      t.references :event, index: true
      t.string :name
      t.string :description
      t.integer :duration
      t.boolean :public, default: true

      t.timestamps null: false
    end
    add_foreign_key :session_formats, :events
  end
end
