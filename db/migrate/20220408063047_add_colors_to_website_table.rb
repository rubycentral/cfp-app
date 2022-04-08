class AddColorsToWebsiteTable < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :body_background_color, :string, default: "#FFFFFF"
    add_column :websites, :nav_background_color, :string, default: "#FFFFFF"
    add_column :websites, :nav_text_color, :string, default: "#000000"
    add_column :websites, :nav_link_hover, :string, default: "#000000"
    add_column :websites, :main_content_background, :string, default: "#FFFFFF"
  end
end
