class Entities::Person < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Person'
  end

  def self.external_entity_name
    'Customer'
  end

  def self.mapper_class
    PersonMapper
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.references
    {
      record_references: %w(),
      id_references: %W(lines/id notes/id)
    }

  end

  class PersonMapper
    extend HashMapper
    SHOPIFY_NOTE_TAG = 'shopify'
    SHOPIFY_NOTE_ID = 'shopify001'
    # normalize from Connec to Shopify
    # denormalize from Shopify to Connec
    # map from (connect_field) to (shopify_field)

    before_denormalize do |input, output|
      # If the customer'd company field is not blank we'll use that to name the company
      if input['addresses'] &&  input['addresses'].first && !input['addresses'].first['company'].blank?
        output[:opts] = {attach_to_organization: input['addresses'].first['company']}
      else
        # Otherwise we create a company with the Customer First + Last name
        organization_name = "#{input['first_name']} #{input['last_name']}'s organisation"
        output[:opts] = {attach_to_organization: organization_name.strip }
      end

      input
    end

    map from('first_name'), to('first_name')
    map from('last_name'), to('last_name'), default: 'Undefined'

    map from('address_work/billing/line1'), to('default_address/address1')
    map from('address_work/billing/line2'), to('default_address/address2')
    map from('address_work/billing/city'), to('default_address/city')
    map from('address_work/billing/region'), to('default_address/province')
    map from('address_work/billing/postal_code'), to('default_address/zip')
    map from('address_work/billing/country'), to('default_address/country')

    map from('email/address'), to('email')

    after_normalize do |input, output|
      notes = input['notes'].select { |note| note['tag'] == SHOPIFY_NOTE_TAG} if input['notes'].present?
      #Shopify only supports one note per customer, so we are selecting the last
      note = notes.last if notes
      output[:note] = note['description'] if note
      output
    end

    after_denormalize do |input, output|
      external_note = {id: SHOPIFY_NOTE_ID, description: input['note'], tag: SHOPIFY_NOTE_TAG} if input['note']
      output[:notes] = [external_note] if external_note
      output
    end
  end
end
