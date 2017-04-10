class Entities::Item < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Item'
  end

  def self.external_entity_name
    'Variant'
  end

  def self.public_external_entity_name
    'Products'
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

  def self.currency_check_fields
    %w(sale_price purchase_price)
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

  def get_external_entities(external_entity_name, last_synchronization = nil)
    entities = @external_client.find('Product')
    variants = entities.map { |product|
      self.class.get_product_variants(product)
    }.flatten
    variants
  end

  def push_entities_to_connec(mapped_external_entities_with_idmaps)
    super
    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      entity = mapped_external_entity_with_idmap[:entity]
      connec_id = mapped_external_entity_with_idmap[:idmap].connec_id
      product_id_map = Maestrano::Connector::Rails::IdMap.find_or_create_by(external_id: entity[:product_id], connec_id: connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: @organization.id)
      product_id_map.update_attributes(last_push_to_external: Time.now, message: nil, name: entity[:product_name])
    end
  end

  # We override this method to avoid pushing currency updates for items
  # As currency might have changed company wide but an item might be historical
  def push_entities_to_connec_to(mapped_external_entities_with_idmaps, connec_entity_name)
    return unless @organization.push_to_connec_enabled?(self)

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize} to Connec! #{connec_entity_name.pluralize}")

    entity_updates = []

    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      # We separate the updates in order to remove the currency field
      id = mapped_external_entity_with_idmap[:idmap].connec_id
      entity_updates << mapped_external_entity_with_idmap if id

      id_map = mapped_external_entity_with_idmap[:idmap]
      # If the currency matches we send the whole hash
      next unless id_map&.metadata&.dig(:ignore_currency_update)
      # Otherwise we delete the fields listed
      self.class.currency_check_fields.each do |field|
        mapped_external_entity_with_idmap[:entity].delete(field)
      end
    end
    # For updates we delete the currency
    entity_updates.each do |mapped_external_entity_with_idmap|
      mapped_external_entity_with_idmap[:entity][:sale_price]&.delete('currency')
    end

    mapped_external_entities_with_idmaps.concat(entity_updates)

    proc = ->(mapped_external_entity_with_idmap) { batch_op('post', mapped_external_entity_with_idmap[:entity], nil, self.class.normalize_connec_entity_name(connec_entity_name)) }
    batch_calls(mapped_external_entities_with_idmaps, proc, connec_entity_name)
  end


  def before_sync(last_synchronization_date)
    @opts[:base_currency] ||= @external_client.currency
  end

  def push_entity_to_external(mapped_connec_entity_with_idmap, external_entity_name)
    idmap = mapped_connec_entity_with_idmap[:idmap]
    variant = mapped_connec_entity_with_idmap[:entity]

    begin
      if idmap.external_id.blank?
        product = {
            body_html: variant[:body_html],
            variants: [variant],
            title: variant[:product_title]
        }
        created_entity = @external_client.update('Product', product)

        idmap.update_attributes(external_id: created_entity['variants'][0]['id'], last_push_to_external: Time.now, message: nil)
        product_id_map = Maestrano::Connector::Rails::IdMap.find_or_create_by(external_id: created_entity['id'], connec_id: idmap.connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: @organization.id)
        product_id_map.update_attributes(last_push_to_external: Time.now, message: nil, name: variant[:product_title])

        return {idmap: idmap}
      else
        variant[:id] = idmap.external_id
        product_id_map = Maestrano::Connector::Rails::IdMap.find_by(connec_id: idmap.connec_id, connec_entity: self.class.connec_entity_name, external_entity: 'product', organization_id: @organization.id)
        product = {
            id: product_id_map.external_id,
            title: variant[:product_title],
            variants: [variant],
            body_html: variant[:body_html],
        }
        variant[:product_id] = product[:id]
        @external_client.update('Product', product)
        @external_client.update('Variant', variant)
        idmap.update_attributes(last_push_to_external: Time.now, message: nil)
        product_id_map.update_attributes(last_push_to_external: Time.now, message: nil)
      end
    rescue => e
      # Store External error
      Maestrano::Connector::Rails::ConnectorLogger.log('error', @organization, "Error while pushing to #{Maestrano::Connector::Rails::External.external_name}: #{e}")
      Maestrano::Connector::Rails::ConnectorLogger.log('debug', @organization, "Error while pushing backtrace: #{e.backtrace.join("\n\t")}")
      idmap.update(message: e.message.truncate(255))
    end
    nil
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

    after_normalize do |input, output, opts|
      output[:product_title] = input['name'] || 'Title not available'
      output[:inventory_management] = input['is_inventoried'] ? 'shopify' : nil
      output[:sku] =  input['reference'] || input['code']
      keep_price = currency_matches?(input.dig('sale_price', 'currency'), opts[:opts][:base_currency])

      unless keep_price
        output.delete(:price)
        idmap = input['idmap']
        idmap.update_attributes(metadata: idmap.metadata.merge(ignore_currency_update: true)) if idmap
      end

      output
    end

    after_denormalize do |input, output, opts|
      output[:product_name] = input['product_title'] || ''
      name_join = [output[:product_name]]
      if input['title'] && input['title'] != 'Default Title'
        name_join << input['title']
      end
      # input['product_title'] or  input['title'] can be blank, this is to not have empty space
      output[:name] = name_join.reject(&:blank?).join(' ')
      output[:is_inventoried] = input['inventory_management'] == 'shopify'
      output[:quantity_on_hand] = output[:quantity_available]
      output[:reference] = input['sku'] if input['sku']
      base_currency = opts[:opts][:base_currency]
      output[:sale_price].merge!(currency: base_currency) unless output[:sale_price].blank?
      output[:purchase_price] ||= {}
      output[:purchase_price][:currency] = base_currency

      output
    end

    def self.currency_matches?(currency, base_currency)
      base_currency.present? && currency == base_currency
    end
  end
end
