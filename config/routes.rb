Rails.application.routes.draw do
  root "pay_periods#calendar"

  resources :pay_periods do
    member do
      post :update_with_adjacent_pay_periods
    end
    collection do
      get :calendar
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
