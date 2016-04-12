Maestrano['default'].configure do |config|

  # ==> Environment configuration
  # The environment to connect to.
  # If set to 'production' then all Single Sign-On (SSO) and API requests
  # will be made to maestrano.com
  # If set to 'test' then requests will be made to api-sandbox.maestrano.io
  # The api-sandbox allows you to easily test integration scenarios.
  # More details on http://api-sandbox.maestrano.io
  #
  config.environment = Rails.env.development? ? 'local' : 'production'

  if ENV['connec_host']
    config.connec.host = ENV['connec_host']
  end
  if ENV['api_host']
    config.api.host = ENV['api_host']
  end

  # ==> Application host
  # This is your application host (e.g: my-app.com) which is ultimately
  # used to redirect users to the right SAML url during SSO handshake.
  #
  if ENV['app_host']
    config.app.host = ENV['app_host']
  elsif Rails.env.development?
    config.app.host = 'http://localhost:3001'
  elsif Rails.env.uat?
    config.app.host = 'http://connector-shopify-uat.herokuapp.com'
  else
    config.app.host = 'http://connector-shopify.herokuapp.com'
  end

  # ==> App ID & API key
  # Your application App ID and API key which you can retrieve on http://maestrano.com
  # via your cloud partner dashboard.
  # For testing you can retrieve/generate an api.id and api.key from the API Sandbox directly
  # on http://api-sandbox.maestrano.io
  #
  config.api.id = ENV['connec_api_id']
  config.api.key = ENV['connec_api_key']

  # ==> Single Sign-On activation
  # Enable/Disable single sign-on. When troubleshooting authentication issues
  # you might want to disable SSO temporarily
  #
  # config.sso.enabled = true

  # ==> Single Sign-On Identity Manager
  # By default we consider that the domain managing user identification
  # is the same as your application host (see above config.app.host parameter)
  # If you have a dedicated domain managing user identification and therefore
  # responsible for the single sign-on handshake (e.g: https://idp.my-app.com)
  # then you can specify it below
  #

  # ==> SSO Initialization endpoint
  # This is your application path to the SAML endpoint that allows users to
  # initialize SSO authentication. Upon reaching this endpoint users your
  # application will automatically create a SAML request and redirect the user
  # to Maestrano. Maestrano will then authenticate and authorize the user. Upon
  # authorization the user gets redirected to your application consumer endpoint
  # (see below) for initial setup and/or login.
  #
  # The controller for this path is automatically
  # generated when you run 'rake maestrano:install' and is available at
  # <rails_root>/app/controllers/maestrano/auth/saml.rb
  #
  config.sso.init_path = '/maestrano/auth/saml/init/default'

  # ==> SSO Consumer endpoint
  # This is your application path to the SAML endpoint that allows users to
  # finalize SSO authentication. During the 'consume' action your application
  # sets users (and associated group) up and/or log them in.
  #
  # The controller for this path is automatically
  # generated when you run 'rake maestrano:install' and is available at
  # <rails_root>/app/controllers/maestrano/auth/saml.rb
  #
  # config.sso.consume_path = '/maestrano/auth/saml/consume'

  # ==> Single Logout activation
  # Enable/Disable single logout. When troubleshooting authentication issues
  # you might want to disable SLO temporarily.
  # If set to false then Maestrano::SSO::Session#valid? - which should be
  # used in a controller before filter to check user session - always return true
  #
  # config.sso.slo_enabled = true

  # ==> SSO User creation mode
  # !IMPORTANT
  # On Maestrano users can take several "instances" of your service. You can consider
  # each "instance" as 1) a billing entity and 2) a collaboration group (this is
  # equivalent to a 'customer account' in a commercial world). When users login to
  # your application via single sign-on they actually login via a specific group which
  # is then supposed to determine which data they have access to inside your application.
  #
  # E.g: John and Jack are part of group 1. They should see the same data when they login to
  # your application (employee info, analytics, sales etc..). John is also part of group 2
  # but not Jack. Therefore only John should be able to see the data belonging to group 2.
  #
  # In most application this is done via collaboration/sharing/permission groups which is
  # why a group is required to be created when a new user logs in via a new group (and
  # also for billing purpose - you charge a group, not a user directly).
  #
  # == mode: 'real'
  # In an ideal world a user should be able to belong to several groups in your application.
  # In this case you would set the 'sso.creation_mode' to 'real' which means that the uid
  # and email we pass to you are the actual user email and maestrano universal id.
  #
  # == mode: 'virtual'
  # Now let's say that due to technical constraints your application cannot authorize a user
  # to belong to several groups. Well next time John logs in via a different group there will
  # be a problem: the user already exists (based on uid or email) and cannot be assigned
  # to a second group. To fix this you can set the 'sso.creation_mode' to 'virtual'. In this
  # mode users get assigned a truly unique uid and email across groups. So next time John logs
  # in a whole new user account can be created for him without any validation problem. In this
  # mode the email we assign to him looks like "usr-sdf54.cld-45aa2@mail.maestrano.com". But don't
  # worry we take care of forwarding any email you would send to this address
  #
  # config.sso.creation_mode = 'real' # or 'virtual'

  # ==> Account Webhooks
  # Single sign on has been setup into your app and Maestrano users are now able
  # to use your service. Great! Wait what happens when a business (group) decides to 
  # stop using your service? Also what happens when a user gets removed from a business?
  # Well the endpoints below are for Maestrano to be able to notify you of such
  # events.
  #
  # Even if the routes look restful we issue only issue DELETE requests for the moment
  # to notify you of any service cancellation (group deletion) or any user being
  # removed from a group.
  #
  # config.webhook.account.groups_path = '/maestrano/account/groups/:id',
  # config.webhook.account.group_users_path = '/maestrano/account/groups/:group_id/users/:id',


  # ==> Connec Subscriptions/Webhook
  # The following section is used to configure the Connec!™ webhooks and which entities
  # you should receive via webhook.
  #
  # == Notification Path
  # This is the path of your application where notifications (created/updated entities) will
  # be POSTed to.
  # You should have a controller matching this path handling the update of your internal entities
  # based on the Connec!™ entities you receive
  #
  config.webhook.connec.notifications_path = '/maestrano/connec/notifications/default'
  #
  # == Subscriptions
  # This is the list of entities (organizations,people,invoices etc.) for which you want to be
  # notified upon creation/update in Connec!™
  # 
  config.webhook.connec.subscriptions = {
      accounts: false,
      company: true,
      employees: false,
      events: false,
      event_orders: false,
      invoices: true,
      items: true,
      journals: false,
      opportunities: false,
      organizations: true,
      payments: false,
      pay_items: false,
      pay_schedules: false,
      pay_stubs: false,
      pay_runs: false,
      people: true,
      projects: false,
      purchase_orders: false,
      quotes: false,
      sales_orders: true,
      tax_codes: false,
      tax_rates: false,
      time_activities: false,
      time_sheets: false,
      venues: false,
      warehouses: false,
      work_locations: false
  }
end

# Maestrano UAT
Maestrano['maestrano-uat'].configure do |config|
  config.environment = 'uat'
  if Rails.env.development?
    config.app.host = 'http://localhost:3001'
  elsif Rails.env.uat?
    config.app.host = 'http://connector-shopify-uat.herokuapp.com'
  else
    config.app.host = 'http://connector-shopify.herokuapp.com'
  end

  config.api.host = 'https://uat.maestrano.io'
  config.api.id = ENV['maestrano_uat_connec_api_id']
  config.api.key = ENV['maestrano_uat_connec_api_key']

  config.sso.init_path = '/maestrano/auth/saml/init/maestrano-uat'
  config.sso.consume_path = '/maestrano/auth/saml/consume/maestrano-uat'
  config.sso.x509_certificate = "-----BEGIN CERTIFICATE-----\nMIIDezCCAuSgAwIBAgIJAMzy+weDPp7qMA0GCSqGSIb3DQEBBQUAMIGGMQswCQYD\nVQQGEwJBVTEMMAoGA1UECBMDTlNXMQ8wDQYDVQQHEwZTeWRuZXkxGjAYBgNVBAoT\nEU1hZXN0cmFubyBQdHkgTHRkMRYwFAYDVQQDEw1tYWVzdHJhbm8uY29tMSQwIgYJ\nKoZIhvcNAQkBFhVzdXBwb3J0QG1hZXN0cmFuby5jb20wHhcNMTQwMTA0MDUyMzE0\nWhcNMzMxMjMwMDUyMzE0WjCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEP\nMA0GA1UEBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQG\nA1UEAxMNbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVz\ndHJhbm8uY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+2uyQeAOc/iro\nhCyT33RkkWfTGeJ8E/mu9F5ORWoCZ/h2J+QDuzuc69Rf1LoO4wZVQ8LBeWOqMBYz\notYFUIPlPfIBXDNL/stHkpg28WLDpoJM+46WpTAgp89YKgwdAoYODHiUOcO/uXOO\n2i9Ekoa+kxbvBzDJf7uuR/io6GERXwIDAQABo4HuMIHrMB0GA1UdDgQWBBTGRDBT\nie5+fHkB0+SZ5g3WY/D2RTCBuwYDVR0jBIGzMIGwgBTGRDBTie5+fHkB0+SZ5g3W\nY/D2RaGBjKSBiTCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEPMA0GA1UE\nBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQGA1UEAxMN\nbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVzdHJhbm8u\nY29tggkAzPL7B4M+nuowDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOBgQAw\nRxg3rZrML//xbsS3FFXguzXiiNQAvA4KrMWhGh3jVrtzAlN1/okFNy6zuN8gzdKD\nYw2n0c/u3cSpUutIVZOkwQuPCMC1hoP7Ilat6icVewNcHayLBxKgRxpBhr5Sc4av\n3HOW5Bi/eyC7IjeBTbTnpziApEC7uUsBou2rlKmTGw==\n-----END CERTIFICATE-----"
  config.sso.x509_fingerprint = '8a:1e:2e:76:c4:67:80:68:6c:81:18:f7:d3:29:5d:77:f8:79:54:2f'

  config.webhook.connec.notifications_path = '/maestrano/connec/notifications/maestrano-uat'
  config.webhook.connec.subscriptions = {
      accounts: false,
      company: true,
      employees: false,
      events: false,
      event_orders: false,
      invoices: true,
      items: true,
      journals: false,
      opportunities: false,
      organizations: false,
      payments: false,
      pay_items: false,
      pay_schedules: false,
      pay_stubs: false,
      pay_runs: false,
      people: true,
      projects: false,
      purchase_orders: false,
      quotes: false,
      sales_orders: true,
      tax_codes: false,
      tax_rates: false,
      time_activities: false,
      time_sheets: false,
      venues: false,
      warehouses: false,
      work_locations: false
  }
end

# NAB UAT
Maestrano['nab-uat'].configure do |config|
  config.environment = 'uat'
  if Rails.env.development?
    config.app.host = 'http://localhost:3001'
  else
    config.app.host = 'https://connector-shopify-uat.herokuapp.com'
  end

  config.api.host = 'https://api-hub-uat.bio.cd.non.whu.nab.com.au'
  config.api.id = ENV['nab_uat_connec_api_id']
  config.api.key = ENV['nab_uat_connec_api_key']

  config.sso.init_path = '/maestrano/auth/saml/init/nab-uat?settings=true'
  config.sso.consume_path = '/maestrano/auth/saml/consume/nab-uat'
  config.sso.x509_certificate = "-----BEGIN CERTIFICATE-----\nMIIDezCCAuSgAwIBAgIJAMzy+weDPp7qMA0GCSqGSIb3DQEBBQUAMIGGMQswCQYD\nVQQGEwJBVTEMMAoGA1UECBMDTlNXMQ8wDQYDVQQHEwZTeWRuZXkxGjAYBgNVBAoT\nEU1hZXN0cmFubyBQdHkgTHRkMRYwFAYDVQQDEw1tYWVzdHJhbm8uY29tMSQwIgYJ\nKoZIhvcNAQkBFhVzdXBwb3J0QG1hZXN0cmFuby5jb20wHhcNMTQwMTA0MDUyMzE0\nWhcNMzMxMjMwMDUyMzE0WjCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEP\nMA0GA1UEBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQG\nA1UEAxMNbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVz\ndHJhbm8uY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+2uyQeAOc/iro\nhCyT33RkkWfTGeJ8E/mu9F5ORWoCZ/h2J+QDuzuc69Rf1LoO4wZVQ8LBeWOqMBYz\notYFUIPlPfIBXDNL/stHkpg28WLDpoJM+46WpTAgp89YKgwdAoYODHiUOcO/uXOO\n2i9Ekoa+kxbvBzDJf7uuR/io6GERXwIDAQABo4HuMIHrMB0GA1UdDgQWBBTGRDBT\nie5+fHkB0+SZ5g3WY/D2RTCBuwYDVR0jBIGzMIGwgBTGRDBTie5+fHkB0+SZ5g3W\nY/D2RaGBjKSBiTCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEPMA0GA1UE\nBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQGA1UEAxMN\nbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVzdHJhbm8u\nY29tggkAzPL7B4M+nuowDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOBgQAw\nRxg3rZrML//xbsS3FFXguzXiiNQAvA4KrMWhGh3jVrtzAlN1/okFNy6zuN8gzdKD\nYw2n0c/u3cSpUutIVZOkwQuPCMC1hoP7Ilat6icVewNcHayLBxKgRxpBhr5Sc4av\n3HOW5Bi/eyC7IjeBTbTnpziApEC7uUsBou2rlKmTGw==\n-----END CERTIFICATE-----"
  config.sso.x509_fingerprint = '8a:1e:2e:76:c4:67:80:68:6c:81:18:f7:d3:29:5d:77:f8:79:54:2f'

  config.connec.host = 'https://api-connec-uat.bio.cd.non.whu.nab.com.au'
  config.webhook.connec.notifications_path = '/maestrano/connec/notifications/nab-uat'
  config.webhook.connec.subscriptions = {
      accounts: false,
      company: true,
      employees: false,
      events: false,
      event_orders: false,
      invoices: true,
      items: true,
      journals: false,
      opportunities: false,
      organizations: false,
      payments: false,
      pay_items: false,
      pay_schedules: false,
      pay_stubs: false,
      pay_runs: false,
      people: true,
      projects: false,
      purchase_orders: false,
      quotes: false,
      sales_orders: true,
      tax_codes: false,
      tax_rates: false,
      time_activities: false,
      time_sheets: false,
      venues: false,
      warehouses: false,
      work_locations: false
  }
end

# NAB Production
Maestrano['nab-production'].configure do |config|
  config.environment = 'production'
  if Rails.env.development?
    config.app.host = 'http://localhost:3001'
  else
    config.app.host = 'https://connector-shopify.herokuapp.com'
  end

  config.api.host = 'https://api-hub.bio.nab.com.au'
  config.api.id = ENV['nab_connec_api_id']
  config.api.key = ENV['nab_connec_api_key']

  config.sso.init_path = '/maestrano/auth/saml/init/nab-production?settings=true'
  config.sso.consume_path = '/maestrano/auth/saml/consume/nab-production'
  config.sso.x509_certificate = "-----BEGIN CERTIFICATE-----\nMIIDezCCAuSgAwIBAgIJAPFpcH2rW0pyMA0GCSqGSIb3DQEBBQUAMIGGMQswCQYD\nVQQGEwJBVTEMMAoGA1UECBMDTlNXMQ8wDQYDVQQHEwZTeWRuZXkxGjAYBgNVBAoT\nEU1hZXN0cmFubyBQdHkgTHRkMRYwFAYDVQQDEw1tYWVzdHJhbm8uY29tMSQwIgYJ\nKoZIhvcNAQkBFhVzdXBwb3J0QG1hZXN0cmFuby5jb20wHhcNMTQwMTA0MDUyNDEw\nWhcNMzMxMjMwMDUyNDEwWjCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEP\nMA0GA1UEBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQG\nA1UEAxMNbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVz\ndHJhbm8uY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD3feNNn2xfEz5/\nQvkBIu2keh9NNhobpre8U4r1qC7h7OeInTldmxGL4cLHw4ZAqKbJVrlFWqNevM5V\nZBkDe4mjuVkK6rYK1ZK7eVk59BicRksVKRmdhXbANk/C5sESUsQv1wLZyrF5Iq8m\na9Oy4oYrIsEF2uHzCouTKM5n+O4DkwIDAQABo4HuMIHrMB0GA1UdDgQWBBSd/X0L\n/Pq+ZkHvItMtLnxMCAMdhjCBuwYDVR0jBIGzMIGwgBSd/X0L/Pq+ZkHvItMtLnxM\nCAMdhqGBjKSBiTCBhjELMAkGA1UEBhMCQVUxDDAKBgNVBAgTA05TVzEPMA0GA1UE\nBxMGU3lkbmV5MRowGAYDVQQKExFNYWVzdHJhbm8gUHR5IEx0ZDEWMBQGA1UEAxMN\nbWFlc3RyYW5vLmNvbTEkMCIGCSqGSIb3DQEJARYVc3VwcG9ydEBtYWVzdHJhbm8u\nY29tggkA8WlwfatbSnIwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOBgQDE\nhe/18oRh8EqIhOl0bPk6BG49AkjhZZezrRJkCFp4dZxaBjwZTddwo8O5KHwkFGdy\nyLiPV326dtvXoKa9RFJvoJiSTQLEn5mO1NzWYnBMLtrDWojOe6Ltvn3x0HVo/iHh\nJShjAn6ZYX43Tjl1YXDd1H9O+7/VgEWAQQ32v8p5lA==\n-----END CERTIFICATE-----",
  config.sso.x509_fingerprint = '2f:57:71:e4:40:19:57:37:a6:2c:f0:c5:82:52:2f:2e:41:b7:9d:7e'

  config.connec.host = 'https://api-connec.bio.nab.com.au'
  config.webhook.connec.notifications_path = '/maestrano/connec/notifications/nab-production'
  config.webhook.connec.subscriptions = {
      accounts: false,
      company: true,
      employees: false,
      events: false,
      event_orders: false,
      invoices: true,
      items: true,
      journals: false,
      opportunities: false,
      organizations: false,
      payments: false,
      pay_items: false,
      pay_schedules: false,
      pay_stubs: false,
      pay_runs: false,
      people: true,
      projects: false,
      purchase_orders: false,
      quotes: false,
      sales_orders: true,
      tax_codes: false,
      tax_rates: false,
      time_activities: false,
      time_sheets: false,
      venues: false,
      warehouses: false,
      work_locations: false
  }
end
