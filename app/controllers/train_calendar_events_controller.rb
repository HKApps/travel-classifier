class TrainCalendarEventsController < ApplicationController
  before_action :ensure_logged_in

  def index
    @event_to_process = CalendarEvent.find_by google_id: training_data_queue.first
    if @event_to_process
      classifier = TravelClassifierService.new(@event_to_process)
      @probability = if classifier.fetch_probability.present?
        classifier.fetch_probability
      else
        classifier.classify!
      end
    end
  end

  def travel_event
    event = CalendarEvent.find_by google_id: training_data_queue.first
    event.classification = 'travel'
    if event.save
      training_data_queue.pop
      CalendarEventTrainerWorker.perform_async(event.id)
    end
    redirect_to :train_calendar_events
  end

  def nontravel_event
    event = CalendarEvent.find_by google_id: training_data_queue.first
    event.classification = 'nontravel'
    if event.save
      training_data_queue.pop
      CalendarEventTrainerWorker.perform_async(event.id)
    end
    redirect_to :train_calendar_events
  end

  private

  def training_data_queue
    @training_data_queue ||= TrainingDataQueue.new
  end

  def travel_classifier
    @travel_classifier ||= TravelClassifierService.new
  end
end
