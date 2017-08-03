ActiveAdmin.register Maestrano::Connector::Rails::IdMap do
  actions :all, :except => [:new]

  menu label: "IdMaps", priority: 4

  permit_params :id, :connec_id, :connec_entity, :external_id, :external_entity,
                :organization, :last_push_to_connec, :last_push_to_external, :created_at,
                :updated_at, :to_connec, :to_external, :name, :message, :external_inactive,
                :metadata

end
