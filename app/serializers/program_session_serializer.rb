class ProgramSessionSerializer < ActiveModel::Serializer
  attributes :title, :abstract, :format, :track, :tags, :id, :video_url, :slides_url
  has_many :speakers

  def tags
    object.proposal.try(:review_tags)
  end

  def format
    object.session_format.try(:name)
  end

  def track
    object.track.try(:name)
  end
end
