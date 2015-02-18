class UserCreationService
  def self.create_or_update!(auth)
    credentials = auth['credentials']
    info        = auth['info']
    User.find_or_initialize_by(email: info['email'], google_id: info['uid']).tap do |user|
      user.first_name    = info['first_name']
      user.last_name     = info['last_name']
      user.gender        = info['gender']
      user.access_token  = credentials['token']
      user.photo         = info['image']
      user.refresh_token = credentials['refresh_token']
      user.expires_at    = Time.at(credentials['expires_at']).to_datetime
      if user.changed?
        user.save!
      end
      UserCalendarFetcherWorker.perform_async(user.id)
    end
  end
end
