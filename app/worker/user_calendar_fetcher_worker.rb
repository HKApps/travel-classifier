class UserCalendarFetcherWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    UserCalendarService.process(user)
  end
end
