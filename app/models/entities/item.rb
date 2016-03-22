class Entities::Item < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Item'
  end

  def self.external_entity_name
    'Product'
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

  def get_external_entities(client, last_synchronization, organization, opts={})
    entities = super
    @products_first_variant = {}
    entities.each do |entity|
      @products_first_variant[entity['id']] = entity['variants'][0]['id']
    end
  end


  def consolidate_and_map_data(connec_entities, external_entities, organization, opts={})
    items_with_variant = group_items_variants(connec_entities)
    super(items_with_variant, external_entities, organization, opts)
  end

  def push_entities_to_connec(connec_client, mapped_external_entities_with_idmaps, organization)
    # 1/ push the orders
    self.push_entities_to_connec_to(connec_client, mapped_external_entities_with_idmaps, self.class.connec_entity_name, organization)
    variants = []
    mapped_external_entities_with_idmaps.each do |mapped_external_entities_with_idmap|
      parent_connect_id = mapped_external_entities_with_idmap[:idmap].connec_id
      product = mapped_external_entities_with_idmap[:entity]
      product[:variants].each do |variant|
        variant[:parent_item_id] = parent_connect_id
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_id: variant[:external_id], connec_entity: self.class.connec_entity_name.downcase, external_entity: 'variant', organization_id: organization.id)
        variants.push({entity: variant, idmap: idmap || create_variant_id_map(variant, organization)})
      end if product[:variants]
    end
    # 2/ push the variants
    self.push_entities_to_connec_to(connec_client, variants, self.class.connec_entity_name, organization)
  end

  def push_entities_to_external(external_client, mapped_connec_entities_with_idmaps, organization)
    mapped_connec_entities_with_idmaps.each do |mapped_connec_entity_with_idmap|
      product = mapped_connec_entity_with_idmap[:entity]
      product_id_map = mapped_connec_entity_with_idmap[:idmap]
      variants = product[:variants]
      product_id = product_id_map.external_id
      if variants.count == 1
        variants[0][:id] = @products_first_variant[product_id.to_i].to_s
        variants[0][:product_id] = product_id
      else
        variants.each do |variant|
          idmap = Maestrano::Connector::Rails::IdMap.find_by(connec_id: variant[:connec_id], connec_entity: self.class.connec_entity_name.downcase, external_entity: 'variant', organization_id: organization.id)
          variant[:id] = idmap.external_id if idmap
          variant[:product_id] = product_id
        end
      end

    end
    super(external_client, mapped_connec_entities_with_idmaps, organization)
  end

  private
  def create_variant_id_map(variant, organization)
    Maestrano::Connector::Rails::IdMap.create(external_id: variant[:external_id], connec_entity: connec_entity_name, external_entity: 'variant', organization_id: organization.id, name: variant[:name])
  end

  # regroup the items that are variants (with parentid nil) to their parents in a variants field
  def group_items_variants(connec_entities)
    items_with_variant = []
    # create default value with a mutable empty array
    item_variants = Hash.new { |h, k| h[k] = [] }
    connec_entities.each do |item|
      parent_id = item['parent_item_id']
      if parent_id
        item_variants[parent_id].push item
      else
        items_with_variant.push item
      end
    end
    items_with_variant.each do |parent_item|
      parent_item['variants'] = item_variants[parent_item['id']]
      # get the max of the updated time on all the variant
      parent_item['updated_at'] = parent_item['variants'].map { |x| x['updated_at'].to_time }.push(parent_item['updated_at'].to_time).max.iso8601
    end
    items_with_variant
  end

  class VariantMapper
    extend HashMapper
    map from('id'), to('connec_id')
    map from('external_id'), to('id')
    map from('name'), to('title')

    map from('code'), to('sku')
    map from('sale_price/net_amount'), to('price')
    map from('quantity_available'), to('inventory_quantity', &:to_i)

    map from('weight'), to('weight')
    map from('weight_unit'), to('weight_unit')


    after_normalize do |input, output|
      # convert description to options
      options = input['description'].split('|')
      options.each_with_index do |val, index|
        output["option#{index+1}".to_sym] = val
      end
      output[:inventory_management] = input['is_inventoried'] ? 'shopify' : nil
      output
    end

    after_denormalize do |input, output|
      index = 0
      options = []
      while option = input["option#{index+1}"]
        options.push option
        index +=1
      end
      output[:description] = options.join('|')
      output[:is_inventoried] = input['inventory_management'] == 'shopify'
      output
    end

  end

  class ItemMapper
    extend HashMapper
    # normalize from Connec to Shopify
    # denormalize from Shopify to Connec
    # map from (connect_field) to (shopify_field)

    map from('description'), to('body_html')
    map from('name'), to('title')
    map from('/variants'), to('/variants'), using: VariantMapper

    after_normalize do |input, output|
      variants = output[:variants]
      if variants.count == 0
        # generate the default variant
        variants[0] = VariantMapper.normalize(input)
        variants[0].delete :option1
        variants[0].delete :title
      end
      output
    end

    after_denormalize do |input, output|
      if output[:variants] && output[:variants].count == 1
        variant_part = VariantMapper.denormalize(input['variants'][0])
        output[:code] = variant_part[:sku]
        output[:sale_price] = variant_part[:sale_price]
        output[:quantity_available] = variant_part[:quantity_available]
        output[:weight] = variant_part[:weight]
        output[:weight_unit] = variant_part[:weight_unit]
        output[:is_inventoried] = variant_part[:is_inventoried]
        output[:variants] = []
      end
      output
    end

  end

end


