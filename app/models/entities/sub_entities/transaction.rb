class Entities::SubEntities::Transaction < Maestrano::Connector::Rails::SubEntityBase
  def self.entity_name
    'Transaction'
  end

  def self.external?
    true
  end

  def self.mapper_classes
    {
        'Payment' => Entities::SubEntities::PaymentMapper,
        'Opportunity' => Entities::SubEntities::OpportunityMapper
    }
  end

  def self.references
    {
        'Payment' => %w( person_id payment_lines/id payment_lines/linked_transactions/id),
        'Opportunity' => %w(lead_id)
    }
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['order_id']
  end


  def get_external_entities(last_synchronization = nil)
    orders = @external_client.find('Order')
    orders.map { |order|
      transactions = @external_client.find('Transaction', {:order_id => order['id']})
      transactions.each { |transaction|
        transaction['line_items'] = order['line_items']
        transaction['order_id'] = order['id']
        transaction['customer'] = order['customer']
      } if transactions
    }.compact.flatten
  end
end

