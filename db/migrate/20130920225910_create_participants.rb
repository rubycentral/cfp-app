class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :event, index: true
      t.references :person, index: true
      t.string :role

      t.timestamps
    end
  end
end
