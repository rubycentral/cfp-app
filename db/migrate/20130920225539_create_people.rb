class CreatePeople < ActiveRecord::Migration
  def change
    enable_extension "hstore"

    create_table :people do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.hstore :demographics
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
