class AddCustomFieldsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :custom_fields, :text
  end
end
