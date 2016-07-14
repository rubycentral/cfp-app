class Room < ActiveRecord::Base
  belongs_to :event
  has_many :time_slots

  validates :name, uniqueness: true
  scope :by_grid_position, -> {where.not(grid_position: nil).order(:grid_position)}
end

# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  name          :string
#  room_number   :string
#  level         :string
#  address       :string
#  capacity      :integer
#  event_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#  grid_position :integer
#
# Indexes
#
#  index_rooms_on_event_id  (event_id)
#
