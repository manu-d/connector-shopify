ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    columns do
      column do
        panel "Recent Organizations" do
          ul do
            Maestrano::Connector::Rails::Organization.last(5).map do |org|
              li link_to("#{org.name} -- Tenant: #{org.tenant}", admin_maestrano_connector_rails_organization_path(org))
            end
          end
        end
      end
    end

    columns do
      column do
        panel "Recent Users" do
          ul do
            Maestrano::Connector::Rails::User.last(5).map do |user|
              li link_to("#{user.uid} - #{user.email}", admin_maestrano_connector_rails_user_path(user))
            end
          end
        end
      end
    end

    columns do
      column do
        panel "Recent Synchronizations" do
          ul do
            Maestrano::Connector::Rails::Synchronization.last(5).map do |sync|
              li link_to("#{sync.id} - #{sync.created_at} - #{sync.status}", admin_maestrano_connector_rails_synchronization_path(sync))
            end
          end
        end
      end
    end

    columns do
      panel "Info" do
        para "Welcome to ActiveAdmin."
      end
    end
  end
end
