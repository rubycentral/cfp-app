class RemoveDemographicsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :demographics, :hstore
  end
end
