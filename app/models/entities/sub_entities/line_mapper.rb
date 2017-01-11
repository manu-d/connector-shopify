class Entities::SubEntities::LineMapper
  extend HashMapper

  map from('id'), to('id')
  map from('unit_price/net_amount', &:to_f), to('price', &:to_s)
  map from('quantity'), to('quantity')
  map from('description'), to('title')
  map from('item_id'), to('variant_id')

  after_denormalize do |input, output|
	  output[:quantity] ||= 1
    total_line_tax = 0.0

    input['tax_lines']&.each do |line|
      total_line_tax += line['price'].to_f if line['price']
    end

	  output[:unit_price][:tax_amount] = total_line_tax

    output[:description] = "Shipping: #{input['title']}" unless input['variant_id']

	  output
  end
end
