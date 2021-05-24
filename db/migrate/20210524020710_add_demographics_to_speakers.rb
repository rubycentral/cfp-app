class AddDemographicsToSpeakers < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :gender, :string
    add_column :speakers, :age_range, :string
    add_column :speakers, :first_time_speaker, :boolean
    add_reference :speakers, :ethnicity, foreign_key: true
  end
end
