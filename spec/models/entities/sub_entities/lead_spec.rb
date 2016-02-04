require 'spec_helper'

describe Entities::SubEntities::Lead do
  subject { Entities::SubEntities::Lead.new }

  it { expect(subject.external?).to be(true) }
  it { expect(subject.entity_name).to eql('lead') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from lead to lala") } }
    end

    describe 'for a valid entity name' do
      it 'calls denormalize and adds is_lead' do
        expect(Entities::SubEntities::LeadMapper).to receive(:denormalize).with({'FirstName' => 'John'}).and_return({first_name: 'John'})
        expect(subject.map_to('person', {'FirstName' => 'John'}, nil)).to eql({first_name: 'John', is_lead: true})
      end
    end
  end

  describe 'update_entity_to_external' do
    let(:organization) { create(:organization) }
    let(:client) { Restforce.new }

    it 'calls client.update! when lead is not converted' do
      expect(client).to receive(:update!).with('external_name', {'IsConverted' => false, 'Id' => '3456'})
      subject.update_entity_to_external(client, {'IsConverted' => false}, '3456', 'external_name', organization)
    end

    it 'does not call client.update! when lead is converted' do
      expect(client).to_not receive(:update!)
      subject.update_entity_to_external(client, {'IsConverted' => true}, '3456', 'external_name', organization)
    end
  end
end