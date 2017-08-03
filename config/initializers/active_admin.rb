ActiveAdmin.setup do |config|
  config.site_title = "Organizations Management"

  config.namespace :admin do |admin|
    admin.build_menu do |menu|
      menu.add label: "Connector Home", url: "/", priority: 0

      menu.add label: "GitHub" do |sites|
        sites.add label: "Github",
                  url: "http://github.com/#{ENV['GIT_REPO']}"
      end
    end
  end

  config.authentication_method = :authenticate_active_admin_user!

  config.comments_menu = false

  config.batch_actions = true

  config.localize_format = :long

  config.include_default_association_filters = false

  config.footer = 'Maestrano Connectors Admin'
end
