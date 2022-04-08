class AddSansSerifFontToWebsites < ActiveRecord::Migration[6.1]
  def change
    add_column :websites, :sans_serif_font, :string
  end
end
