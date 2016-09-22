class Entities::SubEntities::SalesOrder < Maestrano::Connector::Rails::SubEntityBase

  def self.entity_name
    'Sales Order'
  end

  def self.external?
    false
  end

  def self.can_read_connec?
    false
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['name']
  end

  def self.references
    {'Order' => Entities::SubEntities::SalesOrderMapper.order_references}
  end

  def self.mapper_classes
    {'Order' => Entities::SubEntities::SalesOrderMapper}
  end
end
