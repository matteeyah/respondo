# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  # OmniAuth routing
  get 'auth/:provider/callback', to: 'omniauth_callbacks#authenticate', constraints: { provider: /twitter|google_oauth2|disqus/ }
  get 'auth/failure', to: redirect('/')
  delete :sign_out, to: 'sessions#destroy'

  resources :users, only: [:edit] do
    scope module: :users do
      resources :user_accounts, only: [:destroy]
      resources :personal_access_tokens, only: %i[create destroy]
    end
  end

  resources :brands, only: %i[index edit update] do
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
end
