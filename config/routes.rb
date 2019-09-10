# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :brands, only: %i[index edit] do
    post :add_user
    post :remove_user
    post :refresh_tickets

    scope module: 'brands' do
      resources :tickets, only: [:index]
    end
  end
end
