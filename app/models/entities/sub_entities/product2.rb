class Entities::SubEntities::Product2 < Maestrano::Connector::Rails::SubEntityBase

  def external?
    true
  end

  def entity_name
    'Product2'
  end

  def map_to(name, entity, organization)
    case name
    when 'item'
      Entities::SubEntities::Product2Mapper.denormalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      Name
      ProductCode
      Description
    )
  end

end