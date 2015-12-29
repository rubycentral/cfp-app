# == Schema Information
#
# Table name: speakers
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  bio         :text
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_speakers_on_person_id    (person_id)
#  index_speakers_on_proposal_id  (proposal_id)
#

class SpeakerSerializer < ActiveModel::Serializer
  attributes :name, :bio
end
