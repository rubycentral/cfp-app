class AddDemographicsToSpeakers < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :age_range, :string
    add_column :speakers, :ethnicity, :string
    add_column :speakers, :first_time_speaker, :boolean
    add_column :speakers, :pronouns, :string
  end
end
