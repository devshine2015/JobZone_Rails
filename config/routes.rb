Rails.application.routes.draw do

  resources :companies
  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  ActiveAdmin.routes(self)

  resources :jobs do
    resources :convesations do
      resources :messages
    end
  end

  resources :users do
    put :verify
    put :update_language
    patch :deactivate
    resources :jobs do
      collection do
        get :applied_jobs
        get :recommended_jobs
        get :searches
      end
      put :apply
      resources :convesations do
        resources :messages
      end
    end
  end
end
