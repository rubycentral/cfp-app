class ChangeParticipantsNotificationsToTrue < ActiveRecord::Migration
  def change
      change_column :participants, :notifications, :boolean, :default => true
    end
  end
