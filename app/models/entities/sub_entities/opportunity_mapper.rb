class Entities::SubEntities::OpportunityMapper
  extend HashMapper

  after_denormalize do |input, output|
    output[:sales_stage] = 'Closed Won'
    output[:probability] = 100
    output
  end

  map from('/lead_id'), to('/customer/id')
  map from('name'), to('order_id')
  map from('amount/total_amount'), to('amount')
  map from('amount/currency'), to('currency')
end
