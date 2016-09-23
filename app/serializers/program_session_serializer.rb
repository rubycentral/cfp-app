class ProgramSessionSerializer < ActiveModel::Serializer
  attributes :title, :abstract, :format, :track, :id, :video_url, :slides_url
  has_many :speakers

  def review_tags
    object.proposal.try(:review_tags)
  end

  def format
    object.session_format.try(:name)
  end

  def track
    object.track.try(:name)
  end
end
