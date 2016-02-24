class OauthController < ApplicationController

  def request_omniauth
    org_uid = params[:org_uid]
    shop_name = params[:shop]
    if shop_name.blank?
      flash[:error] = "Shopify Store name is required"
      redirect_to root_url
    else
      organization = Maestrano::Connector::Rails::Organization.find_by_uid(org_uid)

      if organization && is_admin?(current_user, organization)
        auth_params = {
          :state => org_uid,
          :shop =>shop_name
        }

        auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

        redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: "sign_in"
      else
        redirect_to root_url
      end
    end
  end

  # Link an Organization to Shopify OAuth account
  def create_omniauth
    if response = request.env['omniauth.auth']
      organization = current_organization
      if organization && is_admin?(current_user, organization)
        organization.from_omniauth(response)
      end
      flash[:notice] = "Logged in"
      redirect_to root_url
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to root_url
    end


  end

  # Unlink Organization from Shopify
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