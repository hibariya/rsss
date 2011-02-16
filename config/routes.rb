Rsss::Application.routes.draw do
  match '/auth/signout',
        :to => 'sessions#signout',
        :via => :delete,
        :as => :signout

  match '/auth/:provider/callback',
        :to => 'sessions#create'

  match '/dashboard' => 'dashboard#index',
        :via => :get,
        :as  => :dashboard
  
  match '/dashboard/select_feed/:id' => 'dashboard#select_feed',
        :via => :get

  match '/auth' => 'auth#oauth',
        :via => :get,
        :as  => :signin

  match '/user/:user(.:format)' => 'index#user',
        :via => :get,
        :as  => :specified_user

  match '/user/:user/:category(.:format)' => 'index#category',
        :via => :get,
        :as  => :specified_user_category

  match '/updates' => 'index#updates',
        :via => :get,
        :as  => :updates

  resources :sites, :expect => [:create, :destroy, :update]
  resources :users, :expect => [:index, :update]

  root :to => 'index#index'

  match '/:user(.:format)' => 'index#user',
        :via => :get,
        :as  => :user

  match '/:user/:category(.:format)' => 'index#category',
        :via => :get,
        :as  => :user_category
end
