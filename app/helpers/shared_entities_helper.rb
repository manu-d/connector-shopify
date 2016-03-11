module SharedEntitiesHelper
  # list of entities that can generate a Shopify Url
  SUPPORTED_EXTERNAL_ENTITIES = %w(product customer order variant).inject({}) {|hsh, sym| hsh[sym] = true; hsh}

  def link_to_shopify(idmap)
    if SUPPORTED_EXTERNAL_ENTITIES[idmap.external_entity.downcase] && !idmap.external_id.blank?
      link_to idmap.external_id, "https://#{current_organization.oauth_uid}/admin/#{idmap.external_entity.pluralize}/#{idmap.external_id}"
    else
      idmap.external_id
    end
  end
end
