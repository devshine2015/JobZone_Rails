Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :users do
        put :verify
      end

      # devise_scope :user do
      #   post "/sign_in", :to => 'sessions#create'
      #   post "/sign_up", :to => 'registrations#create'
      #   delete "/sign_out", :to => 'sessions#destroy'
      # end
    end
  end
end
