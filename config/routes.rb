Rails.application.routes.draw do
  root to: 'train_calendar_events#index'
  resources :train_calendar_events do
    put :travel_event, on: :collection
    put :nontravel_event, on: :collection
  end
  resources :sessions, only: :new
  resources :train_event_data
  get "/auth/:provider/callback" => 'sessions#create'
end
