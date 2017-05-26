class Entities::SubEntities::PaymentMapper
  extend HashMapper

  def self.payment_references
    {
      record_references: %w(person_id),
      id_references: %w(payment_lines/id payment_lines/linked_transactions/id)
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
    output[:status] = 'ACTIVE'
    output[:payment_lines] = [{linked_transactions: [{id: input['order_id'], class: 'Invoice', applied_amount: input['amount'].to_f}]}]
    output
  end

  map from('/title'), to('/order_id')
  map from('/transaction_number'), to('/transaction_number')
  map from('/transaction_date'), to('/created_at')
  map from('/person_id'), to('/customer/id')
  map from('/amount/currency'), to('/currency')
end
