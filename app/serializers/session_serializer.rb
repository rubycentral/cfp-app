class SessionSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :title, :presenter, :room_name, :track_name, :id, :description

  def description
    if object.proposal
      object.proposal.abstract
    else
      object.description
    end
  end
end
