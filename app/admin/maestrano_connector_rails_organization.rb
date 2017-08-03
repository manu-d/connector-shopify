ActiveAdmin.register Maestrano::Connector::Rails::Organization do
  actions :all, :except => [:new]

  menu label: "Organizations", priority: 1

  index do
    selectable_column
    id_column
    column :provider
    column :uid
    column :name
    column :tenant
    column :oauth_provider
    column :oauth_uid
    column :oauth_name
    column :instance_url
    column :synchronized_entities
    column :created_at
    column :updated_at
    column :sync_enabled
    column :date_filtering_limit
    column :historical_data
    column :org_uid
    column :push_disabled
    column :pull_disabled
    actions
  end

  preserve_default_filters!
  remove_filter :encrypted_oauth_token, :encrypted_refresh_token, :encrypted_oauth_token_iv,
                :encrypted_oauth_token_salt, :encrypted_refresh_token_iv, :encrypted_refresh_token_salt
  filter :tenant, as: :select, collection: proc { Maestrano::Connector::Rails::Organization.all.pluck(:tenant)&.uniq }

  permit_params :provider, :name, :uid, :tenant, :oauth_provider, :oauth_uid, :synchronized_entities,
                :sync_enabled, :historical_data

end
