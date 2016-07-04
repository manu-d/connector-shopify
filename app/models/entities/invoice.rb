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
    %w(sales_order_id person_id lines/item_id lines/id)
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

  def get_external_entities(last_synchronization = nil)
    orders = @external_client.find('Order')
    orders.map { |order|
      self.class.get_order_transaction @external_client, order
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
    map from('/id'), to('/id')
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
    map from('/person_id'), to('/customer/id')
    map from('/transaction_date'), to('/created_at')
    map from('/lines'), to('/line_items'), using: LineMapper


    after_denormalize do |input, output|
      output[:status] = STATUS_MAPPING_INV[input['kind']]
      output[:type] = input['kind'] != 'refund' ? 'CUSTOMER' : 'SUPPLIER'
      output
    end

  end

end



