class Entities::SubEntities::Payment < Maestrano::Connector::Rails::SubEntityBase
  def self.entity_name
    'Payment'
  end

  def self.external?
    false
  end

  def self.mapper_classes
    {'Transaction' => Entities::SubEntities::PaymentMapper}
  end

  def self.references
    {'Transaction' => %w(person_id payment_lines/id payment_lines/linked_transactions/id)}
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['title']
  end

  # Temp
  def self.can_read_connec?
    false
  end

  # Naming issue, can't have two sub entities called payment.rb
  def create_external_entity(mapped_connec_entity, external_entity_name)
    super(mapped_connec_entity, 'Payment')
  end

  def update_external_entity(mapped_connec_entity, external_id, external_entity_name)
    super(mapped_connec_entity, external_id, 'Payment')
  end
end

