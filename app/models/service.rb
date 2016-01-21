class Service < ActiveRecord::Base
  belongs_to :person
end

# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  provider     :string
#  uid          :string
#  person_id    :integer
#  uname        :string
#  uemail       :string
#  created_at   :datetime
#  updated_at   :datetime
#  account_name :string
#
# Indexes
#
#  index_services_on_person_id  (person_id)
#
