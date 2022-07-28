class AddLocationToSpeaker < ActiveRecord::Migration[6.1]
  def change
    add_column :speakers, :houston_or_providence, :string
  end
end
