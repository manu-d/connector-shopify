class Entities::SubEntities::Lead < Maestrano::Connector::Rails::SubEntityBase

  def external?
    true
  end

  def entity_name
    'lead'
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      Entities::SubEntities::LeadMapper.denormalize(entity).merge(is_lead: true)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      Street
      City
      State
      PostalCode
      Country
      Email
      Fax
      LeadSource
      MobilePhone
      Salutation
      FirstName
      LastName
      Phone
      Title
      Description
      Status
      ConvertedDate

    )
  end

  def update_entity_to_external(client, mapped_connec_entity, external_id, external_entity_name, organization)
    # Cannot update a converted lead to SF
    unless mapped_connec_entity['IsConverted']
      super
    end
  end

end