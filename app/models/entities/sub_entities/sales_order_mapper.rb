class Entities::SubEntities::SalesOrderMapper
  extend HashMapper

  def self.order_references
    {
      record_references: %w(person_id lines/item_id lines/tax_code_id),
      id_references: %w(lines/id)
    }
  end

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

  # normalize from Connec to Shopify
  # denormalize from Shopify to Connec
  # map from (connect_field) to (shopify_field)
  map from('/title'), to('/name')
  map from('/person_id'), to('/customer/id')
  map from('/transaction_date'), to('/created_at')
  map from('/transaction_number'), to('/order_number')

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

  map from('/lines'), to('/line_items'), using: Entities::SubEntities::LineMapper

  after_denormalize do |input, output|
    output[:status] = STATUS_MAPPING_INV[input['financial_status']]
    output
  end
end
