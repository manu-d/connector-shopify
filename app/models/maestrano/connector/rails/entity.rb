class Maestrano::Connector::Rails::Entity
  include Maestrano::Connector::Rails::Concerns::Entity

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(organization contact_and_lead item opportunity)
  end

  # Return an array of entities from the external app
  def get_external_entities(client, last_synchronization, organization, opts={})
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Fetching #{@@external_name} #{self.external_entity_name.pluralize}")

    if opts[:full_sync] || last_synchronization.blank?
      fields = self.external_attributes.join(', ')
      entities = client.query("select Id, LastModifiedDate, #{fields} from #{self.external_entity_name} ORDER BY LastModifiedDate DESC")
    else
      entities = []
      ids = client.get_updated(self.external_entity_name, last_synchronization.updated_at, Time.now)['ids']
      ids.each do |id|
        entities << client.find(self.external_entity_name, id)
      end
    end

    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Received data: Source=#{@@external_name}, Entity=#{self.external_entity_name}, Response=#{entities}")
    entities
  end

  def create_entity_to_external(client, mapped_connec_entity, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending create #{external_entity_name}: #{mapped_connec_entity} to #{@@external_name}")
    client.create!(external_entity_name, mapped_connec_entity)
  end

  def update_entity_to_external(client, mapped_connec_entity, external_id, external_entity_name, organization)
    Maestrano::Connector::Rails::ConnectorLogger.log('info', organization, "Sending update #{external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{@@external_name}")
    mapped_connec_entity['Id'] = external_id
    client.update!(external_entity_name, mapped_connec_entity)
  end

  def get_id_from_external_entity_hash(entity)
    entity['Id']
  end

  def get_last_update_date_from_external_entity_hash(entity)
    entity['LastModifiedDate']
  end
end