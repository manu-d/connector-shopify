class OauthController < ApplicationController
  include ApplicationHelper

  OAUTH_FAILURE_TYPE = {invalid_site: 'The shopify site is invalid', invalid_signature: 'The signature is invalid.', invalid_scope: 'The scope is invalid'}

  def oauth_failure
    error_message = 'Oauth failure'
    failure_type = OAUTH_FAILURE_TYPE[env['omniauth.error.type']]
    error_message += ': ' + failure_type if failure_type

    flash[:info] = error_message
    redirect_to root_url
  end

  def request_omniauth
    return redirect_to root_url unless is_admin

    org_uid = params[:org_uid]
    shop_name = params[:shop]
    if shop_name.blank?
      flash[:error] = 'My shopify store url is required'
      return redirect_to root_url
    end
    shop = shop_name.strip + '.myshopify.com'

    auth_params = {
        :state => current_organization.uid,
        :shop => shop
    }
    auth_params = URI.escape(auth_params.collect { |k, v| "#{k}=#{v}" }.join('&'))
    redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: 'sign_in'
  end

  # Link an Organization to Shopify OAuth account
  def create_omniauth
    omniauth_params = request.env['omniauth.params']
    org_uid = omniauth_params['state'] if omniauth_params
    response = request.env['omniauth.auth']

    return redirect_to root_url unless is_admin && org_uid && response

    shop_name = response.uid
    current_organization.from_omniauth(response)

    current_organization.instance_url = "https://#{shop_name}/admin"

    unless current_organization.save
      flash[:alert] = "Oops, your account could not be linked. #{format_errors(current_organization)}"
      return redirect_to root_url
    end

    token = response['credentials']['token']
    Shopify::Webhooks::WebhooksManager.queue_create_webhooks(org_uid, shop_name, token)

  rescue Shopify::Webhooks::WebhooksManager::CreationFailed => e
    Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Webhooks could not be created: #{e}")
  ensure
    if msg = compare_store_company_currency
      return render html: "<script>alert('#{msg}'); window.location.assign('/home/index');</script>".html_safe
    end
    redirect_to root_url
  end

  # Unlink Organization from Shopify
  def destroy_omniauth
    return redirect_to root_url unless is_admin

    shop_name = current_organization.oauth_uid
    token = current_organization.oauth_token
    current_organization.clear_omniauth
    Shopify::Webhooks::WebhooksManager.queue_destroy_webhooks(current_organization.uid, shop_name, token) unless shop_name.blank? || current_organization.uid.blank? || token.blank?

    redirect_to root_url
  end

  private

    def compare_store_company_currency
      connec_client = Maestrano::Connector::Rails::ConnecHelper.get_client(current_organization)
      connec_response_hash = JSON.parse(connec_client.get('company').body)
      connec_currency = connec_response_hash.dig('company', 'currency')

      return if connec_currency.blank?

      shopify_client = Maestrano::Connector::Rails::External.get_client(current_organization)
      shopify_response_hash = shopify_client.find('Shop').first
      shopify_currency = shopify_response_hash['currency']

      return if shopify_currency.blank?

      unless shopify_currency == connec_currency
        "Warning: Your shop has a different currency than your company (#{shopify_currency} vs #{connec_currency}).\\n" +
        "As a result, the price of your products in #{connec_currency} will be set to 0 in Shopify, and you will have to modify them manually.\\n" +
        "Moreover, any price update in Shopify will not be reflected in other apps."
      end
    rescue => e
      Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error when comparing currencies: #{e}")
      nil
    end
end
