class Entities::SubEntities::Payment < Maestrano::Connector::Rails::SubEntityBase
  REFERENCES = %w(person_id payment_lines/id payment_lines/linked_transactions/id)

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
    {'Order' => REFERENCES}
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['title']
  end
end
