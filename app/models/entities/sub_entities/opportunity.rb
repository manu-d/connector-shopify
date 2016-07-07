class Entities::SubEntities::Opportunity < Maestrano::Connector::Rails::SubEntityBase
  def self.entity_name
    'Opportunity'
  end

  def self.external?
    false
  end

  def self.can_read_connec?
    false
  end

  def self.references
    {
      'Transaction' => %w(lead_id)
    }
  end
end

