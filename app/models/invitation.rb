require 'digest/sha1'

class Invitation < ApplicationRecord
  include Invitable

  belongs_to :proposal
  belongs_to :user

  def accept(user)
    transaction do
      self.user = user
      self.state = State::ACCEPTED
      proposal.speakers.create(user: user, event: proposal.event, skip_name_email_validation: true)
      save
    end
  end
end

# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  user_id     :integer
#  email       :string
#  state       :string           default("pending")
#  slug        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_invitations_on_proposal_id            (proposal_id)
#  index_invitations_on_proposal_id_and_email  (proposal_id,email) UNIQUE
#  index_invitations_on_slug                   (slug) UNIQUE
#  index_invitations_on_user_id                (user_id)
#
