class Staff::ProposalsDecorator < Draper::CollectionDecorator
  def to_csv
    CSV.generate do |csv|
      columns = %w[ id uuid state average_rating review_tags_list speaker_name title
        abstract details pitch bio created_at updated_at confirmed_at ]

      csv << columns
      each do |proposal|
        csv << columns.map { |column| proposal.public_send(column) }
      end
    end
  end

  def updated_in_words
    "updated #{h.time_ago_in_words(object.updated_by_speaker_at)} ago"
  end

  # Override the default decorator class
  def decorator_class
    Staff::ProposalDecorator
  end
end
