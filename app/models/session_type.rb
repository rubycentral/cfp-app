class SessionType < ActiveRecord::Base
  belongs_to :event
  has_many :sessions
  has_many :proposals

  validates_presence_of :name, :event
  validates_uniqueness_of :name, scope: :event

  scope :sort_by_name, ->{ order(:name) }
  scope :publicly_viewable, ->{ where(public: true)}
end

# == Schema Information
#
# Table name: session_types
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  duration    :integer
#  public      :boolean          default(TRUE)
#  event_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_session_types_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_e67735874a  (event_id => events.id)
#
