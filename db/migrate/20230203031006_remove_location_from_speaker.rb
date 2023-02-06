class RemoveLocationFromSpeaker < ActiveRecord::Migration[6.1]
  def change
    remove_column :speakers, :houston_or_providence, :boolean
  end
end
