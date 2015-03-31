class AddNotificationsToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :notifications, :boolean, :default => false
  end
end
