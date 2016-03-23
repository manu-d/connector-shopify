Develop
[ ![Codeship Status for maestrano/connector-shopify](https://codeship.com/projects/e35577f0-c6dd-0133-72ca-1ac1b065c1d6/status?branch=develop)](https://codeship.com/projects/138863)
Master
[ ![Codeship Status for maestrano/connector-shopify](https://codeship.com/projects/e35577f0-c6dd-0133-72ca-1ac1b065c1d6/status?branch=master)](https://codeship.com/projects/138863)

# Shopify Connector

The aim of this connector is to implement data sharing between Connec! and Shopify

### Configuration

Configure your Shopify application. To create a new Shopify application:
https://docs.shopify.com/api/guides/introduction/getting-started

Create a configuration file `config/application.yml` with the following settings (complete with your Shopify / Connec! credentials)
```
connec_api_id:
connec_api_key:
shopify_api_id:
shopify_api_key:
```
### Run the connector
#### First time setup
```

# Install JRuby and gems the first time, install redis-server
rvm install jruby-9.0.5.0
gem install bundler
bundle
gem install foreman
sudo apt-get install redis-server
```

#### Start the application
```
export PORT=5678
export RACK_ENV=development
foreman start
```

### Run the connector locally against the Maestrano production environment
Add in the application.yml file the following properties:
```
api_host: 'http://localhost:3000'
connec_host: 'http://localhost:8080'
```

### Test webhooks
Install [ngrok](https://ngrok.com)
Start in on your application port (for example 5678)
```
ngrok http 5678
```
this will open a consoe with an url that is tunnelling to your localhost (for example https://aee0c964.ngrok.io)
update the `app_host` in the application.yml
```
app_host: 'https://aee0c964.ngrok.
```
then edit your app settings in Shopify https://app.shopify.com/services/partners/api_clients/[YOURAPPID]/edit
add the redirection URL:
<p align="center">
  <img src="https://raw.github.com/maestrano/connector-shopify/master/edit-shopify-app-url.png" alt="edit-shopify-app-url.png">
  <br/>
  <br/>
</p>

### Destroy All Webhooks

this command will destroy all the webhooks of the shopify shop linked to the application.
```
org_uid = 'cld-9p9y'
o = Maestrano::Connector::Rails::Organization.find_by_uid(org_uid)
Shopify::Webhooks::WebhooksManager.new(org_uid, o.oauth_uid, o.oauth_token).destroy_all_webhooks
```
```
shop = 'uat-test-store.myshopify.com'
o = Maestrano::Connector::Rails::Organization.find_by_oauth_uid(shop)
Shopify::Webhooks::WebhooksManager.new(o.uid, o.oauth_uid, o.oauth_token).destroy_all_webhooks
```
