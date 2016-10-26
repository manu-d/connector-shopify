source 'https://rubygems.org'

gem 'rails', '~> 4.2'

gem 'turbolinks', '~> 2.5'
gem 'jquery-rails'
gem 'figaro'
gem 'httparty'
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap-validator-rails'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'puma', require: false
gem 'sinatra', require: false

gem 'maestrano-connector-rails', '2.0.0.pre.RC11'
gem 'omniauth-shopify-oauth2', '~> 1.1'
gem 'shopify_api'

gem 'redis-rails'

group :production, :uat do
  gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
  gem 'mysql2', :platforms => :ruby
  gem 'rails_12factor'
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter', platforms: :jruby
  gem 'sqlite3', platforms: :ruby
end

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end
