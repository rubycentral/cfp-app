class Staff::TimeSlotsDecorator < Draper::CollectionDecorator
  def to_csv
    CSV.generate do |csv|

      columns = {
        conference_day: 'Conference Day',
        start_time: 'Start Time',
        end_time: 'End Time',
        room_name: 'Room Name',
        display_title: 'Title',
        display_track_name: 'Track Name',
        session_format_name: 'Session Format',
        display_description: 'Description',
        display_presenter: 'Presenter'
      }

      csv << columns.values
      each do |session|
        csv << columns.keys.map { |column| session.public_send(column) }
      end
    end
  end

  def rows
    map(&:row)
  end
end
