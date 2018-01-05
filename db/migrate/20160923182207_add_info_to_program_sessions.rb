class AddInfoToProgramSessions < ActiveRecord::Migration[5.1]
  def change
    add_column :program_sessions, :info, :text
  end
end
