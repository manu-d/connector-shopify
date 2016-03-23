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
  def self.references
    [{reference_class: Entities::SalesOrder, connec_field: 'sales_order_id', external_field: 'order_id'}]
  end

  def map_to_connec(entity, organization)
    entity['line_items'].each do |item|
      id = item['product_id']
      if id
        idmap = Entities::Item.find_idmap({external_id: id, organization_id: organization.id})
        item['product_id'] = idmap ? idmap.connec_id : ''
      end
    end
    super
  end

  def map_to_external(entity, organization)
    entity['lines'].each do |item|
      id = item['item_id']
      if id
        idmap = Entities::Item.find_idmap({connec_id: id, organization_id: organization.id})
        item['item_id'] = idmap ? idmap.external_id : ''
      end
    end
    super
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    orders = client.find('Order')
    orders.map { |order|
      order_id = order['id']
      transactions = client.find('Transaction', {:order_id => order_id})
      transactions.each do |transaction|
        transaction['line_items'] = order['line_items']
        transaction['order_id'] = order_id
      end
      transactions
    }.flatten
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['created_at'].to_time
  end

  class LineMapper
    extend HashMapper

    map from('/unit_price/net_amount'), to('/price')
    map from('/quantity'), to('/quantity')
    map from('/description'), to('/title')
    map from('/item_id'), to('/product_id')

  end

  class InvoiceMapper
    extend HashMapper

    STATUS_MAPPING = {
        'DRAFT' => 'pending',
        'SUBMITTED' => 'pending',
        'AUTHORISED' => 'pending',
        'PAID' => 'success',
        'VOIDED' => 'failure',
        'INACTIVE' => 'failure'
    }

    STATUS_MAPPING_INV = {
        'pending' => 'DRAFT',
        'failure' => 'VOIDED',
        'success' => 'AUTHORISED',
        'error' => 'VOIDED'
    }
    map from('/sales_order_id'), to('/order_id')
    map from('/transaction_date'), to('/created_at')
    map from('/lines'), to('/line_items'), using: LineMapper

    after_normalize do |input, output|
      output[:financial_status] = STATUS_MAPPING[input['status']]
      output
    end

    after_denormalize do |input, output|
      output[:status] = STATUS_MAPPING_INV[input['financial_status']]
      output[:type] = input['kind'] != 'refund' ? 'CUSTOMER' : 'SUPPLIER'
      output
    end

  end

end



