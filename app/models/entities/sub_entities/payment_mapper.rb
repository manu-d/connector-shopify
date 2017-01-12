class Entities::SubEntities::PaymentMapper
  extend HashMapper

  def self.payment_references
    {
      record_references: %w(person_id),
      id_references: %w(payment_lines/id payment_lines/item_id payment_lines/linked_transactions/id)
    }
  end

  # Mapping to Connec!

  before_denormalize do |input, output|
    input['line_items']&.each do |line|
      line['taxes_included'] = input['taxes_included']
    end

    input
  end

  after_denormalize do |input, output|
    output[:type] = input['kind'] == 'refund' ? 'SUPPLIER' : 'CUSTOMER'
    output[:payment_lines].concat(output.delete(:shipping_lines))

    output[:payment_lines]&.each do |line|
      line.merge!(
        {
          linked_transactions: [
            {
              id: input['order_id'],
              class: 'Invoice'
            }
          ]
        }
      )
    end

    output[:status] = 'ACTIVE'
    output[:transaction_number] = input['transaction_number'] if input['transaction_number']
    output
  end

  map from('/title'), to('/order_id')
  map from('/transaction_date'), to('/created_at')
  map from('/person_id'), to('/customer/id')
  map from('/amount/currency'), to('/currency')
  map from('/payment_lines'), to('/line_items'), using: Entities::SubEntities::LineMapper
  map from('/shipping_lines'), to('/shipping_lines'), using: Entities::SubEntities::LineMapper

end
