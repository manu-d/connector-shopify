class HomeController < ApplicationController
  def index
    @organization = current_organization if current_user
  end
  def redirect_to_external
    # If current user has a linked organization, redirect to the SalesForce instance url
    if current_organization && current_organization.instance_url
      redirect_to current_organization.instance_url
    else
      redirect_to 'https://www.shopify.com/login'
    end
  end

end
