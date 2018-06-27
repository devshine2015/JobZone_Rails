Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  ActiveAdmin.routes(self)

  resources :categories

  resources :jobs do
    resources :conversations do
      resources :messages
    end
  end


  resources :companies do
    patch :update_profile
    patch :update_cover
  end

  resources :users do
    put :verify
    put :send_verification_code
    put :update_language
    patch :deactivate
    patch :update_profile
    patch :update_cover
    get :conversations

    resources :industries
    resources :companies do
      patch :update_profile
      patch :update_cover
    end
    resources :jobs do
      collection do
        get :applied_jobs
        get :recommended_jobs
        get :searches
      end
      put :apply
      resources :conversations do
        resources :messages
      end
    end
  end
end
