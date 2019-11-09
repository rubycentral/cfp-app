class Comment < ApplicationRecord

  belongs_to :proposal
  belongs_to :user

  validates :proposal, :user, presence: true
  validates :body, presence: true

  def public?
    type == "PublicComment"
  end

end

# == Schema Information
#
# Table name: comments
#
#  id          :bigint(8)        not null, primary key
#  proposal_id :bigint(8)
#  user_id     :bigint(8)
#  parent_id   :integer
#  body        :text
#  type        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_comments_on_proposal_id  (proposal_id)
#  index_comments_on_user_id      (user_id)
#
