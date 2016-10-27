class Entities::SubEntities::LineMapper
  extend HashMapper

  map from('unit_price/net_amount'), to('price')
  map from('unit_price/tax_rate'), to('tax_lines[0]/rate')
  map from('quantity'), to('quantity')
  map from('description'), to('title')
  map from('item_id'), to('variant_id')
  map from('id'), to('id')
end
