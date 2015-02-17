class TravelClassifierService
  # may just want to have two different classification
  # services for travel/nontravel and google/nongoogle
  CATEGORIES = ['travel', 'google', 'other']

  def self.classify!(event)
    self.new(event)
  end

  def initialize(event, engine: NaiveBayes)
    @section = "#{event.summary}\n#{event.description}"
    @engine  = engine.new('travel_classifier', *CATEGORIES)
  end

  def classify
    @engine.classify(@section)
  end

end
