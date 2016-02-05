Maestrano['default'].configure do |config|

  # ==> Environment configuration
  # The environment to connect to.
  # If set to 'production' then all Single Sign-On (SSO) and API requests
  # will be made to maestrano.com
  # If set to 'test' then requests will be made to api-sandbox.maestrano.io
  # The api-sandbox allows you to easily test integration scenarios.
  # More details on http://api-sandbox.maestrano.io
  #
  config.environment = Rails.env.development? ? 'test' : 'production'

  # ==> Application host
  # This is your application host (e.g: my-app.com) which is ultimately
  # used to redirect users to the right SAML url during SSO handshake.
  #
  config.app.host = Rails.env.development? ? 'http://localhost:5000' : 'http://connector-shopify.herokuapp.com'
  
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
    invoices: false,
    items: true,
    journals: false,
    opportunities: true,
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
    sales_orders: false,
    tax_codes: false,
    tax_rates: false,
    time_activities: false,
    time_sheets: false,
    venues: false,
    warehouses: false,
    work_locations: false
  }
end

# Example of multi-tenant configuration
Maestrano['other-tenant'].configure do |config|
  config.environment = 'test'
  config.app.host = (config.environment == 'production' ? 'https://my-app.com' : 'http://localhost:3000')

  config.api.id = (config.environment == 'production' ? 'prod_app_id' : 'sandbox_app_id')
  config.api.key = (config.environment == 'production' ? 'prod_api_key' : 'sandbox_api_key')
end