class Entities::Invoice < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'invoice'
  end

  def self.external_entity_name
    'Transaction'
  end

  def self.mapper_class
    InvoiceMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['code']
  end

  def self.object_name_from_external_entity_hash(entity)
    # there is not field from shopify that can be used as an object_name
    nil
  end

  def self.id_from_external_entity_hash(entity)
    entity['order_id']
  end


  def self.can_write_external?
    false
  end

  def self.can_update_external?
    false
  end

  def self.references
    [
        {reference_class: Entities::SalesOrder, connec_field: 'sales_order_id', external_field: 'order_id'},
        {reference_class: Entities::Person, connec_field: 'person_id', external_field: 'customer/id'}
    ]
  end

  def self.get_order_transaction(client, order)
    transaction = client.find('Transaction', {:order_id => order['id']}).last
    if transaction
      transaction['line_items'] = order['line_items']
      transaction['order_id'] = order['id']
      transaction['customer'] = order['customer']
    end
    transaction
  end

  def map_to_connec(entity, organization)
    entity['line_items'].each do |item|
      id = item['variant_id']
      if id
        idmap = Entities::Item.find_idmap({external_id: id, organization_id: organization.id})
        item['variant_id'] = idmap ? idmap.connec_id : ''
      end
    end
    super
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    orders = client.find('Order')
    orders.map { |order|
      self.class.get_order_transaction client, order
    }.compact
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['created_at'].to_time
  end

  class LineMapper
    extend HashMapper

    map from('/unit_price/net_amount'), to('/price')
    map from('/quantity'), to('/quantity')
    map from('/description'), to('/title')
    map from('/item_id'), to('/variant_id')

  end

  class InvoiceMapper
    extend HashMapper

    STATUS_MAPPING_INV = {
        'authorization' => 'SUBMITTED',
        'capture' => 'PAID',
        'sale' => 'PAID',
        'void' => 'VOIDED',
        'refund' => 'AUTHORISED'
    }
    map from('/sales_order_id'), to('/order_id')
    map from('/transaction_date'), to('/created_at')
    map from('/lines'), to('/line_items'), using: LineMapper


    after_denormalize do |input, output|
      output[:status] = STATUS_MAPPING_INV[input['kind']]
      output[:type] = input['kind'] != 'refund' ? 'CUSTOMER' : 'SUPPLIER'
      output
    end

  end

end



