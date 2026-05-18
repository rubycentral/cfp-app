class Identity < ApplicationRecord
  PROVIDER_NAMES = {'github' => 'GitHub', 'twitter' => 'Twitter'}.freeze

  enum :provider, {github: 'github', twitter: 'twitter'}, scopes: false, instance_methods: false

  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: {scope: :provider}
end

# == Schema Information
#
# Table name: identities
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  provider     :string           not null
#  uid          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_name :string
#
# Indexes
#
#  index_identities_on_provider_and_uid  (provider,uid) UNIQUE
#  index_identities_on_user_id           (user_id)
#
