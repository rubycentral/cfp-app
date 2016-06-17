require 'digest/sha1'

class Invitation < ActiveRecord::Base
  include Invitable

  belongs_to :proposal
  belongs_to :user

  before_create :maybe_assign_user

  private

  def maybe_assign_user
    user = User.where("LOWER(email) = ?", self.email.downcase)
    self.user = user.first if user.any?
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
