require 'spec_helper'

describe Entities::Person do

  describe 'instance methods' do
    subject { Entities::Person.new }

    it { expect(subject.connec_entity_name).to eql('Person') }
    it { expect(subject.external_entity_name).to eql('Customer') }
    it { expect(subject.mapper_class).to eql(Entities::Person::PersonMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Robert', 'last_name' => 'Patinson'})).to eql('Robert Patinson') }
    it { expect(subject.object_name_from_external_entity_hash({'first_name' => 'Robert', 'last_name' => 'Patinson'})).to eql('Robert Patinson') }


    describe 'connec_model_to_external_model' do

      let(:connec_hash) {
        {
            first_name: 'Robert',
            last_name: 'Patinson',
            address_work: {
                billing: {
                    line1: 'line1',
                    line2: 'line2',
                    city: 'city',
                    region: 'region',
                    postal_code: 'postal_code',
                    country: 'country'
                }
            },
            email: {
                address: 'robert.patinson@touilaight.com'
            },
            notes: [
                {
                    description: 'very important'
                }
            ],
            opts: {
                create_default_organization: true
            }

        }
      }
      let(:external_hash) {
        {
            first_name: 'Robert',
            last_name: 'Patinson',
            default_address: {
                address1: 'line1',
                address2: 'line2',
                city: 'city',
                province: 'region',
                zip: 'postal_code',
                country: 'country'
            },
            email: 'robert.patinson@touilaight.com',
            note: 'very important'
        }
      }

      it { expect(subject.map_to_connec(external_hash.deep_stringify_keys, nil)).to eql(connec_hash) }
      it { expect(subject.map_to_external(connec_hash.deep_stringify_keys, nil)).to eql(external_hash) }
    end


  end
end