class Entities::SubEntities::Invoice < Maestrano::Connector::Rails::SubEntityBase

  def self.entity_name
    'Invoice'
  end

  def self.external?
    false
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['order_number']
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['transaction_number']
  end

  def self.references
    {'Order' => Entities::SubEntities::InvoiceMapper.invoice_references}
  end
end
