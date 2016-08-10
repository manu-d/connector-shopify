class Entities::SubEntities::InvoiceMapper
  extend HashMapper

  STATUS_MAPPING_INV = {
      'authorization' => 'SUBMITTED',
      'capture' => 'PAID',
      'sale' => 'PAID',
      'void' => 'VOIDED',
      'refund' => 'AUTHORISED'
  }

  map from('/sales_order_id'), to('/order_id')
  map from('/person_id'), to('/customer/id')
  map from('/transaction_date'), to('/created_at')
  map from('/lines'), to('/line_items'), using: Entities::SubEntities::LineMapper

  after_denormalize do |input, output|
    output[:status] = STATUS_MAPPING_INV[input['kind']]
    output[:type] = input['kind'] != 'refund' ? 'CUSTOMER' : 'SUPPLIER'
    output
  end
end
