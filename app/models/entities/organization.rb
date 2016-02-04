class Entities::Organization < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    "Organization"
  end

  def external_entity_name
    "Account"
  end

  def mapper_class
    OrganizationMapper
  end

  def external_attributes
    %w(
      Name
      Industry
      AnnualRevenue
      NumberOfEmployees
      BillingStreet
      BillingCity
      BillingState
      BillingPostalCode
      BillingCountry
      ShippingStreet
      ShippingCity
      ShippingState
      ShippingPostalCode
      ShippingCountry
      Website
      Phone
      Fax
    )
  end

end

class OrganizationMapper
  extend HashMapper

  map from('/name'),  to('/Name')
  map from('/industry'),  to('/Industry')
  map from('/annual_revenue'), to('/AnnualRevenue')
  map from('/number_of_employees'), to('/NumberOfEmployees')

  map from('/address/billing/line1'), to('/BillingStreet')
  map from('/address/billing/city'), to('/BillingCity')
  map from('/address/billing/region'), to('/BillingState')
  map from('/address/billing/postal_code'), to('/BillingPostalCode')
  map from('/address/billing/country'), to('/BillingCountry')

  map from('/address/shipping/line1'), to('/ShippingStreet')
  map from('/address/shipping/city'), to('/ShippingCity')
  map from('/address/shipping/region'), to('/ShippingState')
  map from('/address/shipping/postal_code'), to('/ShippingPostalCode')
  map from('/address/shipping/country'), to('/ShippingCountry')

  map from('/website/url'), to('/Website')
  map from('/phone/landline'), to('/Phone')
  map from('/phone/fax'), to('/Fax')
end

