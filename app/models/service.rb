class Service < ActiveRecord::Base
  belongs_to :person
end

# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  person_id  :integer
#  uname      :string(255)
#  uemail     :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_services_on_person_id  (person_id)
#
