class Entities::SubEntities::Order < Maestrano::Connector::Rails::SubEntityBase
  def self.entity_name
    'Order'
  end

  def self.external?
    true
  end

  def self.mapper_classes
    {'Invoice' => Entities::SubEntities::InvoiceMapper}
  end

  def self.references
    {'Invoice' => Entities::SubEntities::InvoiceMapper.invoice_references}
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['id']
  end


  def get_external_entities(external_entity_name, last_synchronization = nil)
    orders = @external_client.find('Order')
    orders.each do |order|
      order['transactions'] = self.class.get_order_transactions(@external_client, order)
    end
  end

  def self.get_order_transactions(client, order)
    transactions = client.find('Transaction', order_id: order['id'])
    transactions.each do |transaction|
      transaction['line_items'] = order['line_items']
      transaction['order_id'] = order['id']
      transaction['customer'] = order['customer']
      transaction['transaction_number'] = order['order_number']
    end if transactions
  end
end
