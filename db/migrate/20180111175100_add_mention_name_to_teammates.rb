class AddMentionNameToTeammates < ActiveRecord::Migration[5.1]
  def change
    add_column :teammates, :mention_name, :string
  end
end
