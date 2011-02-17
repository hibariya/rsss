Rsss::Application.routes.draw do
  match '/auth/signout',
        :to => 'sessions#signout',
        :via => :delete,
        :as => :signout

  #match '/auth/:provider/callback',
  match '/auth/twitter/callback',
        :via => :get,
        :to => 'sessions#create'

  match '/dashboard' => 'dashboard#index',
        :via => :get,
        :as  => :dashboard
  
  match '/dashboard/select_feed/:id' => 'dashboard#select_feed',
        :via => :get

  match '/updates' => 'misc#updates',
        :via => :get,
        :as  => :updates

  resources :sites, :expect => [:create, :destroy, :update]

  resources :users, :expect => [:index, :update]

  match '/users/:user(.:format)' => 'users#show',
        :via => :get,
        :as  => :specified_user

  match '/users/:user/:category(.:format)' => 'users#category',
        :via => :get,
        :as  => :specified_user_category

  match '/:user(.:format)' => 'users#show',
        :via => :get,
        :as  => :user

  match '/:user/:category(.:format)' => 'users#category',
        :via => :get,
        :as  => :user_category

  root :to => 'misc#about'
end
