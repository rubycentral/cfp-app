class ChangeParticipantsToEventTeammates < ActiveRecord::Migration
  def change
    rename_table :participants, :event_teammates
  end
end
