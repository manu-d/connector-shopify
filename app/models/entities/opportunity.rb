class Entities::Opportunity < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'Opportunity'
  end

  def external_entity_name
    'Opportunity'
  end

  def mapper_class
    OpportunityMapper
  end

  def external_attributes
    %w(
      Amount
      CloseDate
      Description
      NextStep
      Name
      Probability
      StageName
      Type
    )
    #StageName and CloseDate are mandatory for SF
  end
end

class OpportunityMapper
  extend HashMapper

  before_denormalize do |input, output|
    if input['CloseDate']
      input['CloseDate'] = input['CloseDate'].to_time.iso8601
    end
    input
  end

  map from('amount/total_amount'), to('Amount')
  map from('expected_close_date'), to('CloseDate')
  map from('description'), to('Description')
  map from('next_step'), to('NextStep')
  map from('name'), to('Name')
  map from('probability'), to('Probability')
  map from('sales_stage'), to('StageName')
  map from('type'), to('Type')
end

