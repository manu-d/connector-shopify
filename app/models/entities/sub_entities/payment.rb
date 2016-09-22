class Entities::SubEntities::Payment < Maestrano::Connector::Rails::SubEntityBase

  def self.entity_name
    'Payment'
  end

  def self.external?
    false
  end

  def self.can_read_connec?
    false
  end

  def self.references
    {'Transaction' => Entities::SubEntities::PaymentMapper.payment_references}
  end

  def self.mapper_classes
    {'Transaction' => Entities::SubEntities::PaymentMapper}
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['title']
  end
end
