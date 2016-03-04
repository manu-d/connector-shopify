module ApplicationHelper
  def is_admin
    current_user && current_organization && is_admin?(current_user, current_organization)
  end
end
