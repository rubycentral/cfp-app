class CreateSpeakers < ActiveRecord::Migration
  def change
    create_table :speakers do |t|
      t.references :proposal, index: true
      t.references :person, index: true
      t.text :bio

      t.timestamps
    end
  end
end
