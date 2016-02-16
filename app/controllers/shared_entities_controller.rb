class SharedEntitiesController < ApplicationController
  def index
    if is_admin
      @organization = current_organization
      @idmaps = Maestrano::Connector::Rails::IdMap.where(organization_id: @organization.id).order(:connec_entity)
    end
  end

  private
    def is_admin
      current_user && current_organization && is_admin?(current_user, current_organization)
    end
end