class Website::MetaData < ApplicationRecord
  belongs_to :website
  after_initialize :defaults

  has_one_attached :image

  def defaults
    self.title ||= website.event.name
    self.description ||= website.event.name
  end
end
