# typed: strict
# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  # OmniAuth routing
  get 'auth/:provider/callback', to: 'omniauth_callbacks#authenticate', constraints: { provider: /twitter|google_oauth2/ }
  get 'auth/failure', to: redirect('/')
  delete :logout, to: 'sessions#destroy'

  resources :users, only: [:edit] do
    scope module: :users do
      resources :accounts, only: [:destroy]
    end
  end

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
