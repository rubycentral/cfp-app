class InternalComment < Comment
end

# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  parent_id   :integer
#  body        :text
#  type        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_comments_on_person_id    (person_id)
#  index_comments_on_proposal_id  (proposal_id)
#
