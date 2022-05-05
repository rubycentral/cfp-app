class SessionFormatConfig < ApplicationRecord
  belongs_to :website
  belongs_to :session_format

  scope :displayed, ->{ where(display: true) }
  scope :in_order, ->{ order(:position) }

  def slug
    session_format.name.parameterize.pluralize
  end
end
