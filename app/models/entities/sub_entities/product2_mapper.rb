class Entities::SubEntities::Product2Mapper
  extend HashMapper

  map from('code'), to('ProductCode')
  map from('description'), to('Description')
  map from('name'), to('Name')
end