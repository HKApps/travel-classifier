events           = GoogleCalendarService.new(User.last.access_token).fetch_list
test             = NaiveBayes.new 'test', 'travel', 'non-travel', 'google'
nontravel_events = events.map{|x|x['description']}.each_with_index.map{|x,i|i unless x}.compact
google_events    = events.map{|x|x['description']}.each_with_index.map{|x,i|i if x}.compact
nontravel_events.each do |event|
  test.train 'non-travel', "#{events[event]['summary']}\n#{events[event]['description']}"
end
google_events[0..4].each do |event|
  test.train 'google', "#{events[event]['summary']}\n#{events[event]['description']}"
end
test.classify "#{events.last['summary']}\n#{events.last['description']}"
