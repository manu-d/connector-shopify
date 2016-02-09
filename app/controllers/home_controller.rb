class HomeController < ApplicationController
  def index
    @products = []
    if current_user
      @organization = current_organization

      if @organization
        @synchronizations = Maestrano::Connector::Rails::Synchronization.where(organization_id: @organization.id).order(updated_at: :desc).limit(40)
      end

      if @organization.oauth_uid
        begin
          @shop_session = ShopifyAPI::Session.new(@organization.oauth_uid, @organization.oauth_token)
          ShopifyAPI::Base.activate_session(@shop_session)
          @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
        ensure
          ShopifyAPI::Base.clear_session
        end
      end
    end



  end


end
