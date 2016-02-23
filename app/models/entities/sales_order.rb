class Entities::SalesOrder < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'sales_order'
  end

  def external_entity_name
    'Order'
  end

  def mapper_class
    SalesOrderMapper
  end
end

class LineMapper
  extend HashMapper

  map from('/unit_price/net_amount'), to('/price')
  map from('/quantity'), to('/quantity')
  map from('/description'), to('/title')

end

class SalesOrderMapper
  extend HashMapper
  STATUS_MAPPING = {
      'DRAFT' => 'pending',
      'SUBMITTED' => 'pending',
      'AUTHORISED' => 'authorized',
      'PAID' => 'paid',
      'VOIDED' => 'voided',
      'INACTIVE' => 'pending'
  }
  STATUS_MAPPING_INV = {
      'pending' => 'DRAFT',
      'partially_paid' => 'SUBMITTED',
      'authorized' => 'AUTHORISED',
      'paid' => 'PAID',
      'partially_refunded' => 'PAID',
      'refunded' => 'PAID',
      'voided' => 'VOIDED',
  }

  # normalize from Connect to Shopify

  map from('/billing_address/line1'), to('/billing_address/address1')
  map from('/billing_address/line2'), to('/billing_address/address2')
  map from('/billing_address/city'), to('/billing_address/city')
  map from('/billing_address/region'), to('/billing_address/province')
  map from('/billing_address/postal_code'), to('/billing_address/zip')
  map from('/billing_address/country'), to('/billing_address/country_code')

  map from('/shipping_address/line1'), to('/shipping_address/address1')
  map from('/shipping_address/line2'), to('/shipping_address/address2')
  map from('/shipping_address/city'), to('/shipping_address/city')
  map from('/shipping_address/region'), to('/shipping_address/province')
  map from('/shipping_address/postal_code'), to('/shipping_address/zip')
  map from('/shipping_address/country'), to('/shipping_address/country_code')

  map from('/transaction_date'), to('/closed_at')

  map from('/code'), to('/order_number')

  map from('/lines'), to('/line_items'), using: LineMapper


  after_normalize do |input, output|
    output['financial_status'] = STATUS_MAPPING[input['status']]
    output
  end

  after_denormalize do |input, output|
    output['status'] = STATUS_MAPPING_INV[input['financial_status']]
    output
  end

end

