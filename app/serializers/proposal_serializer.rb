class ProposalSerializer < ActiveModel::Serializer
  attributes :title, :abstract, :review_tags, :id, :track, :video_url, :slides_url
  has_many :speakers

  def review_tags
    object.review_tags
  end

  def track
    object.track.name if object.track
  end
end
