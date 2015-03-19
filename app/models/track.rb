class Track < ActiveRecord::Base
  belongs_to :event
  has_many :session

  validates :name, uniqueness: {scope: :event}, presence: true

  def self.count_by_track(event)
    event.tracks.joins(:session).group(:name).count
  end
end

# == Schema Information
#
# Table name: tracks
#
#  id         :integer          not null, primary key
#  name       :text
#  event_id   :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_tracks_on_event_id  (event_id)
#
