class Entities::SubEntities::PaymentMapper
  extend HashMapper

  def self.payment_references
    {
      record_references: %w(person_id),
      id_references: %w(payment_lines/id payment_lines/linked_transactions/id)
    }
  end

  # Mapping to Connec!
  after_denormalize do |input, output|
    output[:type] = input['kind'] == 'refund' ? 'SUPPLIER' : 'CUSTOMER'

    output[:payment_lines] = [
        {
            id: 'shopify-payment',
            amount: input['amount'],
            linked_transactions: [
                {
                    id: input['order_id'],
                    class: 'Invoice'
                },
                {
                    id: input['order_id'],
                    class: 'SalesOrder'
                }
            ]
        }
    ]
    output[:status] = 'ACTIVE'
    output[:transaction_number] = input['transaction_number'] if input['transaction_number']
    output
  end

  map from('/title'), to('/order_id')
  map from('/transaction_date'), to('/created_at')
  map from('/person_id'), to('/customer/id')
  map from('/amount/currency'), to('/currency')
  map from('/amount/total_amount'), to('/amount')
end
