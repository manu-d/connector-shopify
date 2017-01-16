class Entities::SubEntities::LineMapper
  extend HashMapper

  map from('id'), to('id')
  map from('unit_price/net_amount', &:to_f), to('price', &:to_s)
  map from('quantity'), to('quantity')
  map from('description'), to('title')
  map from('item_id'), to('variant_id')

  after_denormalize do |input, output|
	  output[:quantity] ||= 1

    total_line_tax = input['tax_lines']&.map { |line| (line['price']&.to_f / output[:quantity].to_f) }.compact.sum

	  output[:unit_price][:tax_amount] = total_line_tax&.to_f

    output[:description] = "Shipping: #{input['title']}" unless input['variant_id']

	  output
  end
end
