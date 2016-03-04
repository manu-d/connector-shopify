class Entities::Invoice < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'invoice'
  end

  def external_entity_name
    'Transaction'
  end

  def mapper_class
    InvoiceMapper
  end

  def object_name_from_connec_entity_hash(entity)
    entity['description']
  end

  def object_name_from_external_entity_hash(entity)
    entity['title']
  end

  def map_to_connec(entity, organization)
    id = entity['order_id']
    if id
      idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'order', external_id: id, connec_entity: 'sales_order', organization_id: organization.id)
      entity['order_id'] = idmap ? idmap.connec_id : ''
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
    id = entity['sales_order_id']
    if id
      idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'order', connec_id: id, connec_entity: 'sales_order', organization_id: organization.id)
      entity['sales_order_id'] = idmap ? idmap.external_id : ''
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

  def get_external_entities(client, last_synchronization, organization, opts={})
    orders = client.find('Order')
    orders.map { |order|
      transactions = client.find('Transaction', {:order_id => order['id']})
      transactions.each do |transaction|
        transaction['line_items'] = order['line_items']
      end
      transactions
    }.flatten
  end

  def get_last_update_date_from_external_entity_hash(entity)
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



