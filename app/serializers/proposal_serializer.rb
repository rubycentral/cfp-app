class ProposalSerializer < ActiveModel::Serializer
  attributes :title, :abstract, :review_tags, :id, :track
  has_many :speakers

  def review_tags
    object.review_tags
  end

  def track
    object.track.name if object.track
  end
end
