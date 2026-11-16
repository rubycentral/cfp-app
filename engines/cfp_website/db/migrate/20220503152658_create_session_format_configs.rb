class CreateSessionFormatConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :session_format_configs do |t|
      t.belongs_to :website, foreign_key: true
      t.belongs_to :session_format, foreign_key: true
      t.integer :position
      t.string :name
      t.boolean :display

      t.timestamps
    end
  end
end
