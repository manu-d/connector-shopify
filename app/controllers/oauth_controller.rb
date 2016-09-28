class OauthController < ApplicationController

  OAUTH_FAILURE_TYPE = {invalid_site: 'The shopify site is invalid', invalid_signature: 'The signature is invalid.', invalid_scope: 'The scope is invalid'}

  def oauth_failure
    error_message = 'Oauth failure'
    failure_type = OAUTH_FAILURE_TYPE[env['omniauth.error.type']]
    if failure_type
      error_message += ': ' + failure_type
    end
    flash[:info] =error_message
    redirect_to root_url
  end

  def request_omniauth
    org_uid = params[:org_uid]
    shop_name = params[:shop]
    if shop_name.blank?
      flash[:error] = 'My shopify store url is required'
      redirect_to root_url
      return
    end
    shop = shop_name.strip + '.myshopify.com'

    if is_admin
      auth_params = {
          :state => current_organization.uid,
          :shop => shop
      }
      auth_params = URI.escape(auth_params.collect { |k, v| "#{k}=#{v}" }.join('&'))
      redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: 'sign_in'
    else
      redirect_to root_url
    end
  end

  # Link an Organization to Shopify OAuth account
  def create_omniauth
    omniauth_params = request.env['omniauth.params']
    if omniauth_params && org_uid = omniauth_params['state']
      organization = Maestrano::Connector::Rails::Organization.find_by_uid_and_tenant(org_uid, current_user.tenant)
      if organization && is_admin?(current_user, organization) && response = request.env['omniauth.auth']
        shop_name = response.uid
        organization.from_omniauth(response)
        organization.instance_url = "https://#{shop_name}/admin"
        organization.save!

        token = response['credentials']['token']
        Shopify::Webhooks::WebhooksManager.queue_create_webhooks(org_uid, shop_name, token)

      end
    end
    redirect_to root_url
  end

  # Unlink Organization from Shopify
  def destroy_omniauth
    organization = Maestrano::Connector::Rails::Organization.find_by_id(params[:organization_id])
    if organization && is_admin?(current_user, organization)
      shop_name = organization.oauth_uid
      token = organization.oauth_token
      organization.oauth_uid = nil
      organization.oauth_token = nil
      organization.refresh_token = nil
      organization.sync_enabled = false
      organization.save
      Shopify::Webhooks::WebhooksManager.queue_destroy_webhooks(organization.uid, shop_name, token) unless shop_name.blank? || organization.uid.blank? || token.blank?
    end

    redirect_to root_url
  end
end
