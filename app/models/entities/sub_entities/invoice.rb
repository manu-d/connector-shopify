class Entities::SubEntities::Invoice < Maestrano::Connector::Rails::SubEntityBase

  def self.entity_name
    'Invoice'
  end

  def self.external?
    false
  end

  def self.references
    {'Order' => Entities::SubEntities::InvoiceMapper.invoice_references}
  end
end
