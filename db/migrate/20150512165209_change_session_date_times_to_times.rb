class ChangeSessionDateTimesToTimes < ActiveRecord::Migration
  def change
    # Manually altered table to ensure that data is cast correctly from datetime to time
    execute("ALTER TABLE sessions ALTER start_time TYPE time;")
    execute("ALTER TABLE sessions ALTER end_time TYPE time;")
  end
end
