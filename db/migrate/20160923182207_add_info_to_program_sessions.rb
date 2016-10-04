class AddInfoToProgramSessions < ActiveRecord::Migration
  def change
    add_column :program_sessions, :info, :text
  end
end
