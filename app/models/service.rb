class Service < ActiveRecord::Base
  belongs_to :user
end

# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  provider     :string
#  uid          :string
#  user_id      :integer
#  uname        :string
#  account_name :string
#  uemail       :string
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_services_on_user_id  (user_id)
#
