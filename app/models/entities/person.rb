class Entities::Person < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'Person'
  end

  def external_entity_name
    'Customer'
  end

  def mapper_class
    PersonMapper
  end

  def object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def object_name_from_external_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  class PersonMapper
    extend HashMapper
    # normalize from Connec to Shopify
    # denormalize from Shopify to Connec
    # map from (connect_field) to (shopify_field)

    before_denormalize do |input, output|
      output[:opts] = {create_default_organization: true}
      input
    end


    map from('first_name'), to('first_name')
    map from('last_name'), to('last_name'), default: 'Undefined'

    map from('address_work/billing/line1'), to('addresses[0]/address1')
    map from('address_work/billing/line2'), to('addresses[0]/address2')
    map from('address_work/billing/city'), to('addresses[0]/city')
    map from('address_work/billing/region'), to('addresses[0]/province')
    map from('address_work/billing/postal_code'), to('addresses[0]/zip')
    map from('address_work/billing/country'), to('addresses[0]/country')


    map from('email/address'), to('email')
    map from('notes[0]/description'), to('note')

  end

end



