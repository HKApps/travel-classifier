class TrainingDataQueue
  QUEUE_NAME = 'training_data_queue'

  def push(id)
    redis.rpush(QUEUE_NAME, id)
  end

  def pop
    redis.lpop(QUEUE_NAME)
  end

  def first
    redis.lindex(QUEUE_NAME, 0)
  end

  def range(start_i, end_i)
    redis.lrange(QUEUE_NAME, start_i, end_i)
  end

  def length
    redis.llen(QUEUE_NAME)
  end

  private

  def redis
    @redis ||= Redis.new
  end

end
