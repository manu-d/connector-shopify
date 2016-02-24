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
end

class PersonMapper
  extend HashMapper
  # normalize from Connec to Shopify
  # denormalize from Shopify to Connec
  # map from (connect_field) to (shopify_field)

  before_denormalize do |input, output|
    output[:opts] = {'create_default_organization' => true}
    input
  end


  map from('first_name'), to('first_name')
  map from('last_name'), to('last_name'), default: 'Undefined'

  map from('address_work/billing/line1'), to('default_address.address1')
  map from('address_work/billing/line2'), to('default_address.address2')
  map from('address_work/billing/city'), to('default_address.city')
  map from('address_work/billing/region'), to('default_address.province')
  map from('address_work/billing/postal_code'), to('default_address.zip')
  map from('address_work/billing/country'), to('default_address.country')


  map from('email/address'), to('email')
  map from('notes[0]/description'), to('note')

end

