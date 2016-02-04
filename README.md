# SalesForce Connector

The aim of this connector is to implement data sharing between Connec! and SalesForce

### Configuration
Configure your SalesForce application. To create a new SalesForce application: http://geekymartian.com/articles/ruby-on-rails-4-salesforce-oauth-implementation/

Create a configuration file `config/application.yml` with the following settigns (complete with your SalesForce / Connec! credentials)
```
connec_api_id: 
connec_api_key: 
salesforce_client_id: 
salesforce_client_secret: 
```

### Run the connector locally against the Maestrano production environment
In the initialize `config/initializers/maestrano.rb`
```
config.app.host = 'http://localhost:3001'
```

### Run the connector
```
rvm install jruby-9.0.4.0
gem install bundler
bundle
rails s -p 3001
```

### Heroku
Start the Delayed Jobs manually with the command
```
heroku run bundle exec rake jobs:work
```
