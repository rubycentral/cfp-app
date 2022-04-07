class AddDomainsToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :domains, :string
  end
end
