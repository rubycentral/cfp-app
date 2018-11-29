class CreateProgramSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :program_sessions do |t|
      t.references :event, index: true
      t.references :proposal, index: true
      t.text :title
      t.text :abstract
      t.references :track, index: true
      t.references :session_format, index: true
      t.text :state, default: ProgramSession::DRAFT

      t.timestamps null: false
    end
  end
end
