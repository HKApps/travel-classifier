class GoogleCalendarService
  def initialize(access_token)
    client.authorization.access_token = access_token
  end

  def fetch_list
    payload = client.execute(
      :api_method => calendar_api.events.list,
      :parameters => {'calendarId' => 'primary', 'status' => 'confirmed', timeMin: DateTime.now.to_s},
      :headers => {'Content-Type' => 'application/json'}
    )
    JSON.parse(payload.body)['items']
  end

  private

  def calendar_api
    client.discovered_api('calendar', 'v3')
  end

  def client
    @client ||= Google::APIClient.new(
      application_name: 'Hi Bryce',
      application_version: '1.0.0'
    )
  end
end
