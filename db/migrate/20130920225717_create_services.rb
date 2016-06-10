class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :provider
      t.string :uid
      t.references :person, index: true
      t.string :uname
      t.string :account_name
      t.string :uemail

      t.timestamps
    end
  end
end
