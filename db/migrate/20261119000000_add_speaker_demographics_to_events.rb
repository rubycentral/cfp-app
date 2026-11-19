class AddSpeakerDemographicsToEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :speaker_demographics, :boolean, default: false, null: false
    # Existing events were created when the demographic questions were always asked
    execute 'UPDATE events SET speaker_demographics = TRUE'
  end

  def down
    remove_column :events, :speaker_demographics
  end
end
