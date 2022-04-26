class AddDescriptionToSponsor < ActiveRecord::Migration[6.1]
  def change
    add_column :sponsors, :description, :text
    add_column :sponsors, :offer_headline, :string
    add_column :sponsors, :offer_text, :text
    add_column :sponsors, :offer_url, :string
  end
end
