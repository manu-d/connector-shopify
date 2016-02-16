class SynchronizationsController < ApplicationController
  def index
    if current_user
      @organization = current_organization
      @synchronizations = Maestrano::Connector::Rails::Synchronization.where(organization_id: @organization.id).order(updated_at: :desc).limit(40) if @organization
    end
  end
end