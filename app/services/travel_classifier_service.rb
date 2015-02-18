class TravelClassifierService
  # may just want to have two different classification
  # services for travel/nontravel and google/nongoogle
  CATEGORIES = ['travel', 'nontravel']

  def self.classify!(event)
    self.new(event).classify!
  end

  def self.train(event)
    self.new(event).train(event.classification)
  end

  def initialize(event, engine: NaiveBayes)
    @event   = event
    @section = "#{event.summary}\n#{event.description}"
    @engine  = engine.new('travel_classifier', *CATEGORIES)
  end

  def classify!
    return {} unless @engine.ready_to_classify?
    @probability = @engine.classify(@section)
    save
    @probability
  end

  def train(category)
    @engine.train(category, @section)
    self
  end

  def save
    if @probability
      redis.hset("travel_classifier:results:#{@event.id}", @probability.first, @probability.last)
      puts 'Saved!'
    else
      {}
    end
  end

  def fetch_probability
    redis.hgetall("travel_classifier:results:#{@event.id}")
  end

  private

  def redis
    @redis ||= Redis.new
  end
end
