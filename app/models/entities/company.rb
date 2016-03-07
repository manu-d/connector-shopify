class Entities::Company < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'Company'
  end

  def external_entity_name
    'Shop'
  end

  def singleton?
    true
  end

  def object_name_from_connec_entity_hash(entity)
    entity['name']
  end

  def object_name_from_external_entity_hash(entity)
    entity['name']
  end

  def mapper_class
    CompanyMapper
  end

  # Shopify Shop is a Read-Only Resource
  def update_external_entity(client, mapped_connec_entity, external_id, external_entity_name, organization)
    # do nothing
  end
  def create_external_entity(client, mapped_connec_entity, external_entity_name, organization)
    # do nothing
  end

  class CompanyMapper
    extend HashMapper


    map from('/name'), to('/name')
    map from('/timezone'), to('/timezone')
    map from('/email/address'), to('/email')

    map from('/website/url'), to('/domain')
    map from('/phone/landline'), to('/phone')

    map from('/address/billing/line1'), to('/address1')
    map from('/address/billing/city'), to('/city')
    map from('/address/billing/region'), to('/province')
    map from('/address/billing/postal_code'), to('/zip')
    map from('/address/billing/country'), to('/country_code')

    map from('/currency'), to('/currency')

  end
end