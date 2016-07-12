class AddSessionAndTrackToProposal < ActiveRecord::Migration
  def change
    change_table :proposals do |t|
      t.references :session_format, index: true
      t.references :track, index: true
    end
  end
end
