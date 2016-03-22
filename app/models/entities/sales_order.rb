class Entities::SalesOrder < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'sales_order'
  end

  def self.external_entity_name
    'Order'
  end

  def self.mapper_class
    SalesOrderMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['title']
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['name']
  end

  def map_to_connec(entity, organization)
    if entity['customer']
      customer_id = entity['customer']['id']
      if customer_id
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'customer', external_id: customer_id, connec_entity: 'person', organization_id: organization.id)
        entity['customer']['id'] = idmap ? idmap.connec_id : ''
      end
    end

    entity['line_items'].each do |item|
      id = item['product_id']
      if id
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'product', external_id: id, connec_entity: 'item', organization_id: organization.id)
        item['product_id'] = idmap ? idmap.connec_id : ''
      end
    end
    super
  end

  def map_to_external(entity, organization)
    person_id = entity['person_id']
    if person_id
      idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'customer', connec_id: person_id, connec_entity: 'person', organization_id: organization.id)
      entity['person_id'] = idmap ? idmap.external_id : ''
    end

    entity['lines'].each do |item|
      id = item['item_id']
      if id
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'product', connec_id: id, connec_entity: 'item', organization_id: organization.id)
        item['item_id'] = idmap ? idmap.external_id : ''
      end
    end

    super
  end

  class LineMapper
    extend HashMapper

    map from('/unit_price/net_amount'), to('/price')
    map from('/quantity'), to('/quantity')
    map from('/description'), to('/title')
    map from('/item_id'), to('/product_id')
  end

  class SalesOrderMapper
    extend HashMapper
    STATUS_MAPPING = {
        'DRAFT' => 'pending',
        'SUBMITTED' => 'pending',
        'AUTHORISED' => 'authorized',
        'PAID' => 'paid',
        'VOIDED' => 'voided',
        'INACTIVE' => 'pending'
    }
    STATUS_MAPPING_INV = {
        'pending' => 'DRAFT',
        'partially_paid' => 'SUBMITTED',
        'authorized' => 'AUTHORISED',
        'paid' => 'PAID',
        'partially_refunded' => 'PAID',
        'refunded' => 'PAID',
        'voided' => 'VOIDED',
    }

    # normalize from Connec to Shopify
    # denormalize from Shopify to Connec
    # map from (connect_field) to (shopify_field)
    map from('/title'), to('/name')
    map from('/person_id'), to('/customer/id')
    map from('/transaction_date'), to('/closed_at')
    map from('/transaction_number'), to('/order_number')

    map from('/billing_address/line1'), to('/billing_address/address1')
    map from('/billing_address/line2'), to('/billing_address/address2')
    map from('/billing_address/city'), to('/billing_address/city')
    map from('/billing_address/region'), to('/billing_address/province')
    map from('/billing_address/postal_code'), to('/billing_address/zip')
    map from('/billing_address/country'), to('/billing_address/country_code')

    map from('/shipping_address/line1'), to('/shipping_address/address1')
    map from('/shipping_address/line2'), to('/shipping_address/address2')
    map from('/shipping_address/city'), to('/shipping_address/city')
    map from('/shipping_address/region'), to('/shipping_address/province')
    map from('/shipping_address/postal_code'), to('/shipping_address/zip')
    map from('/shipping_address/country'), to('/shipping_address/country_code')


    map from('/lines'), to('/line_items'), using: LineMapper


    after_normalize do |input, output|
      output[:financial_status] = STATUS_MAPPING[input['status']]
      output
    end

    after_denormalize do |input, output|
      output[:status] = STATUS_MAPPING_INV[input['financial_status']]
      output
    end
  end


end

