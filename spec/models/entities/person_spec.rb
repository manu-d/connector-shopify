require 'spec_helper'

describe Entities::Person do
  describe 'class methods' do
    subject { Entities::Person }

    it { expect(subject.connec_entity_name).to eql('Person') }
    it { expect(subject.external_entity_name).to eql('Customer') }
    it { expect(subject.mapper_class).to eql(Entities::Person::PersonMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Robert', 'last_name' => 'Patinson'})).to eql('Robert Patinson') }
    it { expect(subject.object_name_from_external_entity_hash({'first_name' => 'Robert', 'last_name' => 'Patinson'})).to eql('Robert Patinson') }
  end

  describe 'instance methods' do
    let!(:organization) { create(:organization) }
    subject { Entities::Person.new(organization,Maestrano::Connector::Rails::ConnecHelper.get_client(organization),nil) }

    describe 'connec_model_to_external_model' do

      let(:connec_hash) {
        {
            first_name: 'Robert',
            last_name: 'Patinson',
            full_name: 'Robert Patinson',
            address_work: {
                billing: {
                    line1: 'line1',
                    line2: 'line2',
                    city: 'city',
                    region: 'region',
                    postal_code: 'postal_code',
                    country: 'AU'
                }
            },
            phone_work: {
              landline: '0208 111 222 33'
            },
            email: {
                address: 'robert.patinson@touilaight.com'
            },
            notes: [
              {
                id: [
                  {
                    id: "shopify001",
                    provider: organization.oauth_provider,
                    realm: organization.oauth_uid
                  }
                ],
              description: "very important",
              tag: "shopify"}
            ],
            opts: {
                attach_to_organization: "Robert Patinson"
            }

        }
      }
      let(:external_hash) {
        {
            id: 'id',
            first_name: 'Robert',
            last_name: 'Patinson',
            default_address: {
              address1: "line1",
              address2: "line2",
              city: "city",
              province: "region",
              zip: "postal_code",
              country_code: "AU",
              phone: "0208 111 222 33"
            },
            addresses: [
              {
                address1: 'line1',
                address2: 'line2',
                city: 'city',
                province: 'region',
                zip: 'postal_code',
                country_code: 'AU',
                phone: '0208 111 222 33'
              }
            ],
            email: 'robert.patinson@touilaight.com',
            note: 'very important'
        }
      }

      it { expect(subject.map_to_connec(external_hash.with_indifferent_access)).to eql(connec_hash.merge({id:[{id:'id', provider: organization.oauth_provider, realm: organization.oauth_uid}]}).with_indifferent_access) }
      it { expect(subject.map_to_external(connec_hash.with_indifferent_access)).to eql(external_hash.with_indifferent_access.except(:id)) }

      context 'with company' do
        before {
            external_hash[:default_address].merge!(company: 'Pty Ltd')
        }

        it { expect(subject.map_to_connec(external_hash.with_indifferent_access)).to eql(connec_hash.merge({id:[{id:'id', provider: organization.oauth_provider, realm: organization.oauth_uid}], opts: {attach_to_organization: "Pty Ltd"}}).with_indifferent_access) }
      end
    end


  end
end
