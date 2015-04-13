class AddUpdatedBySpeakerAtToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :updated_by_speaker_at, :datetime
    reversible do |dir|
      dir.up do
        execute("update proposals set updated_by_speaker_at = updated_at")
      end
    end
  end
end
