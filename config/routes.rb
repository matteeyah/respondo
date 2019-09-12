# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create', as: 'login'
  get 'auth/failure', to: redirect('/')

  resources :brands, only: %i[index edit] do
    scope module: :brands do
      resources :tickets, only: [:index] do
        post :reply
        post :invert_status

        collection do
          post :refresh
        end
      end

      resources :users, only: %i[create destroy]
    end
  end
end
