Rails.application.routes.draw do
  # Register the Devise/Warden mapping without exposing Devise's HTML routes.
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      get "status", to: "status#show"
      get "auth/csrf", to: "csrf#show"
      post "auth/register", to: "registrations#create"
      patch "auth/confirmation", to: "confirmations#update"
      post "auth/login", to: "sessions#create"
      delete "auth/logout", to: "sessions#destroy"
      get "auth/me", to: "sessions#show"
      get "permissions", to: "permissions#index"
      get "roles", to: "roles#index"
      post "roles", to: "roles#create"
      get "roles/:key", to: "roles#show"
      patch "roles/:key", to: "roles#update"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
