# This migration comes from maestrano_connector_rails_engine (originally 20160427112250)
class AddInactiveToIdmaps < ActiveRecord::Migration
  def change
    add_column :id_maps, :external_inactive, :boolean, default: false
  end
end