class OauthController < ApplicationController

  def request_omniauth
    org_uid = params[:org_uid]
    shop_name = params[:shop]
    if shop_name.blank?
      flash[:error] = 'My shopify store url is required'
      redirect_to root_url
    elsif !shop_name.end_with? 'myshopify.com'
      flash[:error] = 'My shopify store url is required with myshopify.com'
      redirect_to root_url
    else
      if is_admin
        auth_params = {
          :state => current_organization.uid,
          :shop =>shop_name
        }
        auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))
        redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: 'sign_in'
      else
        redirect_to root_url
      end
    end
  end

  # Link an Organization to Shopify OAuth account
  def create_omniauth
    omniauth_params = request.env['omniauth.params']
    if omniauth_params && org_uid = omniauth_params['state']
      organization = Maestrano::Connector::Rails::Organization.find_by_uid_and_tenant(org_uid, current_user.tenant)
      if organization && is_admin?(current_user, organization)  && response = request.env['omniauth.auth']
          organization.from_omniauth(response)
          shop_name = response.uid
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
      organization.save
      Shopify::Webhooks::WebhooksManager.queue_destroy_webhooks(organization.uid, shop_name, token) unless shop_name.blank?
    end

    redirect_to root_url
  end
end