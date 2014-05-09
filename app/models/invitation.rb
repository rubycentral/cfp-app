require 'digest/sha1'

class Invitation < ActiveRecord::Base
  include Invitable

  belongs_to :proposal
  belongs_to :person

  before_create :maybe_assign_person

  private

  def maybe_assign_person
    person = Person.where("LOWER(email) = ?", self.email.downcase)
    self.person = person.first if person.any?
  end
end

# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  email       :string(255)
#  state       :string(255)      default("pending")
#  slug        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_invitations_on_person_id              (person_id)
#  index_invitations_on_proposal_id            (proposal_id)
#  index_invitations_on_proposal_id_and_email  (proposal_id,email) UNIQUE
#  index_invitations_on_slug                   (slug) UNIQUE
#
