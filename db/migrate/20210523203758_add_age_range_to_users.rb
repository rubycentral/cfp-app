class AddAgeRangeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :age_range, :string
  end
end
