Rsss::Application.routes.draw do
  get 'auth/oauth_callback'
  get 'auth/failure'
  get 'auth/signout'

  match '/dashboard' => 'dashboard#index', :via=>[:get]
  match '/dashboard/select_feed/:id' => 'dashboard#select_feed', :via=>[:get]
  match '/auth' => 'auth#oauth', :via=>[:get]
  match '/user/:user(.:format)' => 'index#user', :via=>[:get]
  match '/user/:user/:category(.:format)' => 'index#category', :via=>[:get]
  match '/updates' => 'index#updates', :via=>[:get]
  resources :sites, :expect=>[:create, :destroy, :update]
  resources :users, :expect=>[:index, :update]

  root :to => 'index#index'

  match '/:user(.:format)' => 'index#user', :via=>[:get]
  match '/:user/:category(.:format)' => 'index#category', :via=>[:get]
end
