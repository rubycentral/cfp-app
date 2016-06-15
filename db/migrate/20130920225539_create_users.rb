class CreateUsers < ActiveRecord::Migration
  def change
    enable_extension "hstore"

    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.hstore :demographics
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
