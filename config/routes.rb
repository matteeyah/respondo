# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :brands, only: %i[index edit] do
    scope module: :brands do
      resources :tickets, only: [:index] do
        collection do
          post :refresh
        end
      end

      resources :users, only: %i[create destroy]
    end
  end
end
