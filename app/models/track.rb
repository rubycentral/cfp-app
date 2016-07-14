class Track < ActiveRecord::Base
  belongs_to :event
  has_many :program_sessions
  has_many :proposals

  validates :name, uniqueness: {scope: :event}, presence: true

  def self.count_by_track(event)
    event.tracks.joins(:program_sessions).group(:name).count
  end
end

# == Schema Information
#
# Table name: tracks
#
#  id          :integer          not null, primary key
#  name        :text
#  event_id    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(250)
#  guidelines  :text
#
# Indexes
#
#  index_tracks_on_event_id  (event_id)
#
