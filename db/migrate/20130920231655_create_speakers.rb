class CreateSpeakers < ActiveRecord::Migration[5.1]
  def change
    create_table :speakers do |t|
      t.references :user, index: true
      t.references :event, index: true
      t.references :proposal, index: true
      t.references :program_session, index: true
      t.string :speaker_name
      t.string :speaker_email
      t.text :bio
      t.text :info

      t.timestamps null: true
    end
  end
end
