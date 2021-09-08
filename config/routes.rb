Rails.application.routes.draw do
  # devise_for :users
  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create, :destroy]
      resources :users, only: [:index, :create, :update] do
        post :forgot_password, on: :collection
        post :reset_password, on: :collection
      end
      resources :organisations, only: [:index, :create, :update]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
