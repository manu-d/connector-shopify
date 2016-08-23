class Entities::SubEntities::Transaction < Maestrano::Connector::Rails::SubEntityBase
  # There is a bug that prevent to save linked_transactions before Connec!@1.1.12
  LINKED_TRANSACTIONS_CONNEC_VERSION = '1.1.12'

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
        'Payment' => Entities::SubEntities::Payment::REFERENCES,
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

  def map_to(name, entity)
    hash = super
    if hash['payment_lines'] && Maestrano::Connector::Rails::ConnecHelper.connec_version_lt?(LINKED_TRANSACTIONS_CONNEC_VERSION, @organization)
      hash['payment_lines'].each { |line| line.delete('linked_transactions') }
    end
    hash
  end
end
