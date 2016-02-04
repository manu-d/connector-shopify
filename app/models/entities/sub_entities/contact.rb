class Entities::SubEntities::Contact < Maestrano::Connector::Rails::SubEntityBase

  def external?
    true
  end

  def entity_name
    'contact'
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      if id = entity['AccountId']
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'account', external_id: id, organization_id: organization.id, connec_entity: 'organization')
        entity['AccountId'] = idmap ? idmap.connec_id : ''
      end
      Entities::SubEntities::ContactMapper.denormalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      AccountId
      Salutation
      FirstName
      LastName
      Title
      Birthdate
      MailingStreet
      MailingCity
      MailingState
      MailingPostalCode
      MailingCountry
      OtherStreet
      OtherCity
      OtherState
      OtherPostalCode
      OtherCountry
      Email
      Phone
      OtherPhone
      MobilePhone
      Fax
      HomePhone
      LeadSource
    )
  end

end