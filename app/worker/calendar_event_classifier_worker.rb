# Generic CalendarEvent classifier even though
# we only have two categories (travel and non-travel).
# Eventually we'd want to run the data through multiple
# classification functions.
class CalendarEventClassifierWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = Event.find event_id
    TravelClassifierService.classify!(event)
  end
end
