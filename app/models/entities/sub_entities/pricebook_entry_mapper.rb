class Entities::SubEntities::PricebookEntryMapper
  extend HashMapper

  map from('sale_price/net_amount'), to('UnitPrice')
  map from('Product2Id'), to('Product2Id') #Fake mapper used to keep the Product2Id after mapping
end