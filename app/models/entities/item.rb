class Entities::Item < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Item'
  end

  def self.external_entity_name
    'Variant'
  end

  def self.mapper_class
    ItemMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['name']
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['title']
  end

  def self.get_product_variants(product)
    product['variants'].each do |variant|
      variant['product_id'] = product['id']
      variant['product_title'] = product['title']
      variant['body_html'] = product['body_html']
      variant['updated_at'] = [variant['updated_at'].to_time, product['updated_at'].to_time].max.iso8601
    end
    product['variants']
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    entities = client.find('Product')
    entities.map { |product|
      self.class.get_product_variants(product)
    }.flatten!
    entities
  end


  def push_entities_to_connec(connec_client, mapped_external_entities_with_idmaps, organization)
    super
    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      entity = mapped_external_entity_with_idmap[:entity]
      connec_id = mapped_external_entity_with_idmap[:idmap].connec_id
      product_id_map = Maestrano::Connector::Rails::IdMap.find_or_create_by(external_id: entity[:product_id], connec_id: connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: organization.id)
      product_id_map.update_attributes(last_push_to_external: Time.now, message: nil, name: entity[:product_name])
    end

  end

  def push_entity_to_external(client, mapped_connec_entity_with_idmap, external_entity_name, organization)
    idmap = mapped_connec_entity_with_idmap[:idmap]
    connec_entity = mapped_connec_entity_with_idmap[:entity]

    begin
      title = connec_entity[:product_title]
      product = {
          body_html: connec_entity[:body_html],
          variants: [connec_entity]
      }
      if idmap.external_id.blank?
        product[:title] =  title
        created_entity = client.update('Product', product)
        idmap.update_attributes(external_id: created_entity['variants'][0]['id'], last_push_to_external: Time.now, message: nil)
        product_id_map = Maestrano::Connector::Rails::IdMap.find_or_create_by(external_id: created_entity['id'], connec_id: idmap.connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: organization.id)
        product_id_map.update_attributes(last_push_to_external: Time.now, message: nil, name: title)
      else
        connec_entity[:id] = idmap.external_id
        product_id_map = Maestrano::Connector::Rails::IdMap.find_by(connec_id: idmap.connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: organization.id)
        product[:id] = product_id_map.external_id
        client.update('Product', product)
        idmap.update_attributes(last_push_to_external: Time.now, message: nil)
        product_id_map.update_attributes(last_push_to_external: Time.now, message: nil)
      end
    rescue => e
      # Store External error
      Maestrano::Connector::Rails::ConnectorLogger.log('error', organization, "Error while pushing to #{Maestrano::Connector::Rails::External.external_name}: #{e}")
      idmap.update_attributes(message: e.message)
    end
  end


  class ItemMapper
    extend HashMapper
    # normalize from Connec to Shopify
    # denormalize from Shopify to Connec
    # map from (connect_field) to (shopify_field)
    map from('description'), to('body_html')
    map from('product_id'), to('product_id')
    map from('sale_price/net_amount'), to('price')
    map from('quantity_available'), to('inventory_quantity', &:to_i)

    map from('weight'), to('weight')
    map from('weight_unit'), to('weight_unit')
    map from('description'), to('body_html')

    after_normalize do |input, output|
      output[:product_title] = input['name']
      output[:inventory_management] = input['is_inventoried'] ? 'shopify' : nil
      output[:sku] =  input['reference'] || input['code']

      output
    end

    after_denormalize do |input, output|
      output[:product_name] = input['product_title'] || ''
      name_join = [output[:product_name]]
      if input['title'] && input['title'] != 'Default Title'
        name_join << input['title']
      end
      # input['product_title'] or  input['title'] can be blank, this is to not have empty space
      output[:name] = name_join.reject(&:blank?).join(' ')
      output[:is_inventoried] = input['inventory_management'] == 'shopify'
      output[:reference] = input['sku'] if input['sku']
      output
    end

  end

end


