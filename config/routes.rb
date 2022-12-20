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
                                 constraints: { provider: /google_oauth2|activedirectory/ }
  get 'auth/:provider/callback', to: 'omniauth_callbacks#brand', constraints: { provider: /twitter|disqus/ }
  get 'auth/failure', to: redirect('/')
  delete :sign_out, to: 'sessions#destroy'

  get :dashboard, to: 'dashboard#index'
  get :settings, to: 'brands#edit'
  get :profile, to: 'users#edit'

  resources :tickets, only: %i[index show update destroy] do
    get :permalink

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

  resources :users, only: [] do
    scope module: :users do
      resources :user_accounts, only: [:destroy]
      resources :personal_access_tokens, only: %i[create destroy]
    end
  end

  resources :brands, only: %i[update] do
    scope module: :brands do
      resources :brand_accounts, only: [:destroy]
      resources :external_tickets, constraints: { format: 'json' }, only: [:create]
      resources :users, only: %i[create destroy]
    end
  end

  resources :subscriptions, constraints: { format: 'json' }, only: [:create]
end
