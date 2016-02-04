class OauthController < ApplicationController

  def request_omniauth
    org_uid = params[:org_uid]
    organization = Maestrano::Connector::Rails::Organization.find_by_uid(org_uid)

    if organization && is_admin?(current_user, organization)
      auth_params = {
        :state => org_uid
      }
      auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

      redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: "sign_in"
    else
      redirect_to root_url
    end
  end

  # Link an Organization to SalesForce OAuth account
  def create_omniauth
    org_uid = params[:state]
    organization = Maestrano::Connector::Rails::Organization.find_by_uid(org_uid)

    if organization && is_admin?(current_user, organization)
      organization.from_omniauth(env["omniauth.auth"])
    end

    redirect_to root_url
  end

  # Unlink Organization from SalesForce
  def destroy_omniauth
    organization = Maestrano::Connector::Rails::Organization.find(params[:organization_id])

    if organization && is_admin?(current_user, organization)
      organization.oauth_uid = nil
      organization.oauth_token = nil
      organization.refresh_token = nil
      organization.save
    end

    redirect_to root_url
  end
end