class AddBlindReviewToEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :blind_review, :boolean, default: false, null: false
    # Existing events were created when blind review was the only mode
    execute 'UPDATE events SET blind_review = TRUE'
  end

  def down
    remove_column :events, :blind_review
  end
end
