Rails.application.routes.draw do
  resources :jobs
  resources :companies
  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  ActiveAdmin.routes(self)
  resources :users do
    put :verify
    put :update_language
    resources :jobs do
      collection do
        get :applied_jobs
      end
      put :apply
    end
  end
end
