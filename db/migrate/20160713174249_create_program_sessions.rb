class CreateProgramSessions < ActiveRecord::Migration
  def change
    create_table :program_sessions do |t|
      t.text :title
      t.text :abstract
      t.text :state, default: ProgramSession::ACTIVE
      t.references :event, index: true
      t.references :proposal, index: true
      t.references :track, index: true
      t.references :session_format, index: true

      t.timestamps null: false
    end
  end
end
