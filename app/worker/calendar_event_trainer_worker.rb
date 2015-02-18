class CalendarEventTrainerWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = CalendarEvent.find event_id
    TravelClassifierService.train(event)
  end
end
