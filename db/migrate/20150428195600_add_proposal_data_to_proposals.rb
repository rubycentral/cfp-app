class AddProposalDataToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :proposal_data, :text
  end
end
