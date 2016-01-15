class Service < ActiveRecord::Base
  belongs_to :person

  # def delete_button
  #   h.button_to h.admin_person_services_path,
  #               method: :delete,
  #               data: {
  #                 confirm:
  #                   'This will delete this service. Are you sure you want to do this? ' +
  #                     'It can not be undone.'
  #               },
  #               class: 'btn btn-danger navbar-btn',
  #               id: 'delete' do
  #     bang('Delete Service')
  #   end
  # end
end

# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  provider     :string(255)
#  uid          :string(255)
#  person_id    :integer
#  uname        :string(255)
#  uemail       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  account_name :string(255)
#
# Indexes
#
#  index_services_on_person_id  (person_id)
#
