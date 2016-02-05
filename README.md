# Shopify Connector

The aim of this connector is to implement data sharing between Connec! and Shopify

### Configuration

Create a configuration file `config/application.yml` with the following settigns (complete with your Shopify / Connec! credentials)
```
connec_api_id: 
connec_api_key: 

```

### Run the connector locally against the Maestrano production environment
In the initialize `config/initializers/maestrano.rb`
```
config.app.host = 'http://localhost:5678'
```

### Run the connector
```
rvm install jruby-9.0.4.0
gem install bundler
bundle
rails s -p 5678
```

### Heroku
Start the Delayed Jobs manually with the command
```
heroku run bundle exec rake jobs:work
```
