class SessionsDecorator < Draper::CollectionDecorator
  def to_csv
    CSV.generate do |csv|
      columns = [ :conference_day, :start_time, :end_time, :title,
        :presenter, :room_name, :track_name, :desc ]

      csv << columns
      each do |session|
        csv << columns.map { |column| session.public_send(column) }
      end
    end
  end

  def rows
    map(&:row)
  end
end
