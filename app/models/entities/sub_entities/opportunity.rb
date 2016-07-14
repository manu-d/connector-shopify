class Entities::SubEntities::Opportunity < Maestrano::Connector::Rails::SubEntityBase

  REFERENCES = %w(lead_id)

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
    {'Order' => REFERENCES}
  end

end

