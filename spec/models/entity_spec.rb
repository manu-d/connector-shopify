require 'spec_helper'

describe Maestrano::Connector::Rails::Entity do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::Entity }

    describe 'self.entities_list' do
      it { expect(subject.entities_list).to be_a(Array) }
    end

    describe 'id_from_external_entity_hash' do
      it { expect(subject.id_from_external_entity_hash({'id' => '1234'})).to eql('1234') }
    end

    describe 'last_update_date_from_external_entity_hash' do
      it {
        Timecop.freeze(Date.today) do
          expect(subject.last_update_date_from_external_entity_hash({'updated_at' => 1.hour.ago.to_s})).to eql(1.hour.ago)
        end
      }
    end
  end

  describe 'instance methods' do
    subject { Maestrano::Connector::Rails::Entity.new }
    let(:organization) { create(:organization) }
    let(:client) { ShopifyClient.new(1,2) }
    let(:external_name) { 'external_name' }
    before {
      allow(subject.class).to receive(:external_entity_name).and_return(external_name)
      allow(subject.class).to receive(:external_attributes).and_return(%w(FirstName LastName))
    }
    describe 'get_external_entities' do

      it 'calls find' do
        expect(client).to receive(:find).with(external_name)
        subject.get_external_entities(client, nil, organization)
      end

      it 'returns the entities' do
        allow(client).to receive(:find).and_return([{'FirstName' => 'John'}])
        expect(subject.get_external_entities(client, nil, organization)).to eql([{'FirstName' => 'John'}])
      end
    end


    describe 'create_external_entity' do
      it 'calls create' do
        expect(client).to receive(:create).with(external_name, {}).and_return('ID')
        expect(subject.create_external_entity(client, {}, external_name, organization)).to eql('ID')
      end
    end

    describe 'update_external_entity' do
      it 'calls update with the id' do
        expect(client).to receive(:update).with(external_name, {'id' => '3456'})
        subject.update_external_entity(client, {}, '3456', external_name, organization)
      end
    end
  end
end



