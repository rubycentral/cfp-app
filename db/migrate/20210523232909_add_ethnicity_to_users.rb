class AddEthnicityToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :ethnicity, foreign_key: true
  end
end
