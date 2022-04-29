class AddDetailFieldsToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :city, :string
    add_column :websites, :location, :text
    add_column :websites, :prospectus_link, :string
    add_column :websites, :twitter_handle, :string
    add_column :websites, :directions, :string
  end
end
