# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  if Rails.env.development?
    require 'resque/server'
    mount Resque::Server, at: '/jobs'
  end

  root to: 'home#index'
  get 'login', controller: :home, action: :login

  # OmniAuth routing
  get 'auth/:provider/callback', to: 'omniauth_callbacks#user',
                                 constraints: { provider: /google_oauth2|azure_activedirectory_v2/ }
  get 'auth/:provider/callback', to: 'omniauth_callbacks#organization',
                                 constraints: { provider: /twitter|linkedin/ }

  get 'auth/failure', to: redirect('/')
  delete :sign_out, to: 'sessions#destroy'

  get :dashboard, to: 'dashboard#show'
  get :settings, to: 'organizations#edit'
  get :profile, to: 'users#edit'

  get :linkedin, to: 'organizations#linkedin'

  resources :tickets, only: %i[index show update destroy] do
    member do
      get :permalink
    end

    collection do
      post :refresh
    end

    scope module: :tickets do
      resources :tags, only: %i[create destroy]
      resources :internal_notes, only: :create
      resources :replies, only: :create

      resource :assignments, only: :create
    end
  end

  resource :user, only: [] do
    scope module: :users do
      resources :user_accounts, only: [:destroy]
      resources :personal_access_tokens, only: %i[create destroy]
    end
  end

  resource :organization, only: %i[update] do
    scope module: :organizations do
      resources :organization_accounts, only: [:destroy]
      resources :users, only: %i[create destroy]
    end
  end

  resources :organizations, only: [] do
    scope module: :organizations do
      resources :external_tickets, constraints: { format: 'json' }, only: [:create]
    end
  end

  resources :subscriptions, constraints: { format: 'json' }, only: [:create]
end
