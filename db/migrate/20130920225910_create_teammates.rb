class CreateTeammates < ActiveRecord::Migration
  def change
    create_table :teammates do |t|
      t.references :event, index: true
      t.references :user, index: true
      t.boolean :notifications, default: true
      t.string :role
      t.string :email
      t.string :state
      t.string :token
      t.timestamp :invited_at
      t.timestamp :accepted_at
      t.timestamp :declined_at
      t.timestamps
    end
  end
end
