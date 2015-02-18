class UserCalendarService
  def self.process(user)
    self.new(user).process
  end

  def initialize(user)
    @user = user
  end

  def process
    events_raw.each do |cal|
      CalendarEvent.find_or_initialize_by(user_id: @user_id, google_id: cal['id']).tap do |event|
        event.link        = cal['link']
        event.summary     = cal['summary']
        event.description = cal['description']
        event.location    = cal['location']
        event.start       = cal['dateTime'].to_datetime if cal['datetime']
        event.end         = cal['dateTime'].to_datetime if cal['datetime']

        if event.changed?
          event.raw = cal
          # Queue up events to be trained
          if event.changes
            training_data_queue.push(event.google_id)
          end
          event.save!
        end

        # Run bayes classification on event
        CalendarEventClassifierWorker.perform_async(event.id)
      end
    end
  end

  def events_raw
    client.fetch_list
  end

  private

  def client
    @client ||= GoogleCalendarService.new(@user.access_token)
  end

  def training_data_queue
    @training_data_queue ||= TrainingDataQueue.new
  end

end
