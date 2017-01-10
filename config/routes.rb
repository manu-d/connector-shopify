Rails.application.routes.draw do
  mount Maestrano::Connector::Rails::Engine, at: '/'

  namespace :webhooks do
    post ':entity/:type/:org_uid' => :receive
  end

  # root 'home#index'
  root 'home#index'
  get 'home/index' => 'home#index'
  get 'home/redirect_to_external' => 'home#redirect_to_external'
  put 'home/update' => 'home#update'
  post 'home/synchronize' => 'home#synchronize'
  get 'synchronizations/index' => 'synchronizations#index'
  get 'shared_entities/index' => 'shared_entities#index'
  get 'admin/delete_webhooks' => 'home#delete_webhooks'


  match 'auth/:provider/request', to: 'oauth#request_omniauth', via: [:get, :post]
  match 'auth/:provider/callback', to: 'oauth#create_omniauth', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout_omniauth', to: 'oauth#destroy_omniauth', as: 'signout_omniauth', via: [:get, :post]

  # Sidekiq Admin
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ENV['SIDEKIQ_USERNAME'].present? && username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end
  mount Sidekiq::Web => '/sidekiq'
end
