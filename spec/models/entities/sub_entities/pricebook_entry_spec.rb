require 'spec_helper'

describe Entities::SubEntities::PricebookEntry do
  subject { Entities::SubEntities::PricebookEntry.new }

  it { expect(subject.external?).to be(true) }
  it { expect(subject.entity_name).to eql('PricebookEntry') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from PricebookEntry to lala") } }
    end

    describe 'for a valid entity name' do
      it 'calls denormalize' do
        expect(Entities::SubEntities::PricebookEntryMapper).to receive(:denormalize).with({})
        subject.map_to('item', {}, nil)
      end
    end
  end

  describe 'push_entities_to_connec_to' do
    let(:organization) { create(:organization) }
    let(:client) { Maestrano::Connec::Client.new(organization.uid)}
    let(:product_id) { '7766DEA' }

    context 'when idmap has no connec_id' do
      let!(:idmap) { create(:idmap, organization: organization, connec_id: nil, connec_entity: 'item', external_id: '133A', external_entity: 'pricebookentry') }

      it 'looks for one' do
        expect(Maestrano::Connector::Rails::IdMap).to receive(:find_by).with(external_id: product_id, external_entity: 'product2', organization_id: organization.id)
        expect{ subject.push_entities_to_connec_to(client, [{entity: {:Product2Id => product_id}, idmap: idmap}], 'item', organization) }.to raise_error("Trying to push a price for a non existing or not pushed product (id: #{product_id})")
      end

      describe 'when one is found' do
        let(:connec_id) { '9887eg-3565ef' }
        let!(:product_idmap) { create(:idmap, organization: organization, connec_id: connec_id, connec_entity: 'item', external_entity: 'product2', external_id: product_id) }

        it 'send an update to connec with it' do
          expect(subject).to receive(:update_entity_to_connec).with(client, {:Product2Id => product_id}, connec_id, 'item', organization)
          subject.push_entities_to_connec_to(client, [{entity: {:Product2Id => product_id}, idmap: idmap}], 'item', organization)
        end
      end
    end

    context 'when idmap has a connec_id' do
      let(:connec_id) { '9887eg-3565ef' }
      let!(:idmap) { create(:idmap, organization: organization, connec_id: connec_id, connec_entity: 'item', external_id: '133A', external_entity: 'pricebookentry') }

      it 'send an update to connec with it' do
        expect(subject).to receive(:update_entity_to_connec).with(client, {:Product2Id => product_id}, connec_id, 'item', organization)
        subject.push_entities_to_connec_to(client, [{entity: {:Product2Id => product_id}, idmap: idmap}], 'item', organization)
      end
    end
  end

  describe 'get_external_entities' do
    let(:client) { Restforce.new }
    let(:organization) { create(:organization) }
    let(:id1) { '567SQF' }
    let(:id2) { '12SQF' }
    before {
      allow(client).to receive(:query).and_return([{'Pricebook2Id' => id1}])
    }

    context 'for standard pricebook entry' do
      it 'does nothing' do
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(id1)
        expect(subject.get_external_entities(client, nil, organization)).to eql([{'Pricebook2Id' => id1}])
      end
    end

    context 'for not standard pricebook entry' do
      it 'deletes them' do
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(id2)
        expect(subject.get_external_entities(client, nil, organization)).to eql([])
      end
    end
  end
end