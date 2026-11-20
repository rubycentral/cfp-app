class Room < ApplicationRecord
  belongs_to :event
  has_many :time_slots

  validates :name, uniqueness: {scope: :event_id}, presence: true
  scope :grid_order, -> { order(:grid_position) }
end

# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  name          :string
#  room_number   :string
#  level         :string
#  address       :string
#  capacity      :integer
#  grid_position :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_rooms_on_event_id_and_grid_position  (event_id,grid_position)
#
