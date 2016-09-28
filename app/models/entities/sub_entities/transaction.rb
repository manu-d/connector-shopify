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
        'Payment' => Entities::SubEntities::PaymentMapper.payment_references,
        'Opportunity' => Entities::SubEntities::Opportunity::REFERENCES
    }
  end

  def self.can_read_external?
    false
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['id']
  end

  def self.last_update_date_from_external_entity_hash(entity)
    entity['created_at'].to_time
  end
end
