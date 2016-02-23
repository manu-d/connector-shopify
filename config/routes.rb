Rails.application.routes.draw do
  root :to => 'home#index'
  mount Maestrano::Connector::Rails::Engine, at: '/'

  # root 'home#index'
  get 'home/index' => 'home#index'
  get 'admin/index' => 'admin#index'
  put 'admin/update' => 'admin#update'
  post 'admin/synchronize' => 'admin#synchronize'
  put 'admin/synchronize' => 'admin#synchronize'
  put 'admin/toggle_sync' => 'admin#toggle_sync'
  get 'synchronizations/index' => 'synchronizations#index'
  get 'shared_entities/index' => 'shared_entities#index'


  match 'auth/:provider/request', to: 'oauth#request_omniauth', via: [:get, :post]
  match 'auth/:provider/callback', to: 'oauth#create_omniauth', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout_omniauth', to: 'oauth#destroy_omniauth', as: 'signout_omniauth', via: [:get, :post]

end
