class Entities::SubEntities::LineMapper
  extend HashMapper

  map from('unit_price/net_amount', &:to_f), to('price', &:to_s)
  map from('quantity'), to('quantity')
  map from('description'), to('title')
  map from('item_id'), to('variant_id')
  map from('id'), to('id')

  after_denormalize do |input, output|
	output[:quantity] ||= 1
	output[:unit_price][:tax_amount] = 0.0
	input[:tax_lines]&.each do |tax|
	  output[:unit_price][:tax_amount] += tax['price'].to_f
	end
	output[:unit_price][:net_amount] -= output[:unit_price][:tax_amount] if input['taxes_included']
	output
  end
end
