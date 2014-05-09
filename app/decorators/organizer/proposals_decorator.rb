class Organizer::ProposalsDecorator < Draper::CollectionDecorator
  def to_csv
    CSV.generate do |csv|
      columns = %w[ id uuid state average_rating review_taggings speaker_name title
        abstract details pitch bio created_at updated_at confirmed_at ]

      csv << columns
      each do |proposal|
        csv << columns.map { |column| proposal.public_send(column) }
      end
    end
  end

  # Override the default decorator class
  def decorator_class
    Organizer::ProposalDecorator
  end
end
