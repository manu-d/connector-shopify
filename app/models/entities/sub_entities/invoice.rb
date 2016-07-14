class Entities::SubEntities::Invoice < Maestrano::Connector::Rails::SubEntityBase

  REFERENCES =  %w(sales_order_id person_id lines/item_id lines/id)

  def self.entity_name
    'Invoice'
  end

  def self.external?
    false
  end

  def self.references
    {'Order' => REFERENCES}
  end

end



