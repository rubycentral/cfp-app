class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.references :event, index: true
      t.string :state, default: 'submitted'
      t.string :uuid
      t.string :title
      t.text :abstract
      t.text :details
      t.text :pitch
      t.text :last_change
      t.text :confirmation_notes
      t.text :proposal_data
      t.datetime :updated_by_speaker_at
      t.timestamp :confirmed_at
      t.timestamps
    end

    add_index :proposals, :uuid, unique: true
  end
end
