module TimeHelpers

  def self.with_correct_time_zone(time)
    Time.parse(time.in_time_zone(Time.zone).strftime("%H:%M"))
  end
end