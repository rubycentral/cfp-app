class Room < ActiveRecord::Base
  belongs_to :event
  has_many :session

  validates :name, uniqueness: true
end

# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  room_number   :string(255)
#  level         :string(255)
#  address       :string(255)
#  capacity      :integer
#  event_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#  grid_position :string(255)
#
# Indexes
#
#  index_rooms_on_event_id  (event_id)
#
