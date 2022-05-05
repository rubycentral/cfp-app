class AddFooterFieldsToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :footer_about_content, :text
    add_column :websites, :footer_copyright, :string
    add_column :websites, :facebook_url, :string
    add_column :websites, :instagram_url, :string
  end
end
