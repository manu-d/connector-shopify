Develop
[ ![Codeship Status for maestrano/connector-shopify](https://codeship.com/projects/e35577f0-c6dd-0133-72ca-1ac1b065c1d6/status?branch=develop)](https://codeship.com/projects/138863)
Master
[ ![Codeship Status for maestrano/connector-shopify](https://codeship.com/projects/e35577f0-c6dd-0133-72ca-1ac1b065c1d6/status?branch=master)](https://codeship.com/projects/138863)

# Shopify Connector

The aim of this connector is to implement data sharing between Connec! and Shopify

### Configuration

Configure your Shopify application. To create a new Shopify application:
https://docs.shopify.com/api/guides/introduction/getting-started

### Create an account on Maestrano's Developer Platform at:

```
https://developer.maestrano.com
```

### Create an application on the Developer Platform:


Documentation can be found here:

[Create a new app](https://maestrano.atlassian.net/wiki/display/DEV/Integrate+your+app+on+partner%27s+marketplaces)

Edit the configuration file `config/application-sample.yml` with the correct credentials (both Shopify's and Maestrano's Developer Platform ones) and rename it `config/application.yml`
```
encryption_key1: ''
encryption_key2: ''

shopify_client_id: 'your_shopify_id'
shopify_client_secret: 'your_shopify_secret'

REDIS_URL: redis://localhost:6379/0/connector-shopify

MNO_DEVPL_HOST: https://developer.maestrano.com
MNO_DEVPL_API_PATH: /api/config/v1/marketplaces
MNO_DEVPL_ENV_NAME: 'shopify-local'
MNO_DEVPL_ENV_KEY: 'your_local_env_key'
MNO_DEVPL_ENV_SECRET: 'your_local_env_secret'
```

### Run the connector locally against the Maestrano UAT environment

### Run the connector
#### First time setup
```
# Install bundler and update your gemset
gem install ruby-2.3.1
gem install foreman
gem install bundler
bundle
```

#### Start the application
```
foreman start
```

#### Launch the Application from Maestrano Developer Sandbox environment
