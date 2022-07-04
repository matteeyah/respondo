# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'
  get 'login', controller: :home, action: :login

  # OmniAuth routing
  get 'auth/:provider/callback', to: 'sessions#create',
                                 constraints: { provider: /twitter|google_oauth2|disqus/ }
  post 'auth/developer/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete :sign_out, to: 'sessions#destroy'

  resources :users, only: [:edit] do
    scope module: :users do
      resources :user_accounts, only: [:destroy]
      resources :personal_access_tokens, only: %i[create destroy]
    end
  end

  resources :brands, only: %i[edit update] do
    scope module: :brands do
      resources :tickets, only: %i[index show] do
        post :reply
        post :internal_note
        post :invert_status

        collection do
          post :refresh
        end
      end

      resources :brand_accounts, only: [:destroy]

      resources :external_tickets, constraints: { format: 'json' }, only: [:create]

      resources :users, only: %i[create destroy]
    end
  end

  resources :subscriptions, constraints: { format: 'json' }, only: [:create]
end
