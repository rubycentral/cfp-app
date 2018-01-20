class AddNotificationPreferenceToTeammates < ActiveRecord::Migration[5.1]
  def change
    add_column :teammates, :notification_preference, :string, default: Teammate::ALL
    remove_column :teammates, :notifications, :boolean
  end
end
