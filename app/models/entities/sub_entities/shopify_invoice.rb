class Entities::SubEntities::ShopifyInvoice < Maestrano::Connector::Rails::SubEntityBase
  def self.entity_name
    'Shopify Invoice'
  end

  def self.external?
    true
  end

  def self.mapper_classes
    {'Invoice' => Entities::SubEntities::InvoiceMapper}
  end

  def self.references
    {'Invoice' => Entities::SubEntities::Invoice::REFERENCES}
  end

  def self.id_from_external_entity_hash(entity)
    entity['order_id']
  end
  def self.object_name_from_external_entity_hash(entity)
    entity['order_id']
  end
  def self.last_update_date_from_external_entity_hash(entity)
    entity['created_at'].to_time
  end

  def self.can_read_external?
    false
  end
end
