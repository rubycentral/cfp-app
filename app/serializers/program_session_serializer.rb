class ProgramSessionSerializer < ActiveModel::Serializer
  attributes :title, :abstract, :format, :track, :tags, :id, :video_url, :slides_url
  has_many :speakers

  def tags
    object.proposal&.review_tags
  end

  def format
    object.session_format&.name
  end

  def track
    object.track&.name
  end
end
