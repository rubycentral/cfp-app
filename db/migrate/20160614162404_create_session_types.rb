class CreateSessionTypes < ActiveRecord::Migration
  def change
    create_table :session_types do |t|
      t.string :name
      t.string :description
      t.integer :duration
      t.boolean :public, default: true
      t.references :event, index: true
      t.timestamps null: false
    end
    add_foreign_key :session_types, :events
  end
end
