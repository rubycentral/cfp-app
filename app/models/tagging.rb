class Tagging < ApplicationRecord
  belongs_to :proposal

  scope :proposal, -> { where(internal: false).order('tag ASC') }
  scope :review, -> { where(internal: true).order('tag ASC') }

  def self.count_by_tag(event)
    event.taggings.group(:tag).count
  end

  # 'one, two, three' -> ['one','two','three']
  # does some clean up for extra spaces and commas
  def self.tags_string_to_array(string)
    (string || '').split(',').map(&:strip).reject(&:blank?).uniq
  end
end

# == Schema Information
#
# Table name: taggings
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  tag         :string
#  internal    :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_taggings_on_proposal_id  (proposal_id)
#
