source 'https://rubygems.org'
ruby '2.2.3', :engine => 'jruby', :engine_version => '9.0.5.0'

gem 'rails', '~> 4.2'

gem 'turbolinks', '~> 2.5'
gem 'jquery-rails'
gem 'figaro'
gem 'httparty'
gem 'uglifier', '>= 1.3.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'puma', require: false
gem 'sinatra', require: false

gem 'maestrano-connector-rails', '~> 1.4'
gem 'maestrano-rails', '~> 0.15'

gem 'omniauth-shopify-oauth2', '~> 1.1'
gem 'shopify_api'

# jQuery based field validator for Twitter Bootstrap 3.
gem 'bootstrap-validator-rails'

gem 'redis-rails'

group :production, :uat do
  gem 'rails_12factor'
  gem 'activerecord-jdbcpostgresql-adapter', :platforms => :jruby
  gem 'pg', :platforms => :ruby
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
  gem 'sqlite3', :platforms => :ruby
end

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end
