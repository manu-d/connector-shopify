require 'spec_helper'

describe Entities::SubEntities::Item do
  subject { Entities::SubEntities::Item.new }

  it { expect(subject.external?).to be(false) }
  it { expect(subject.entity_name).to eql('item') }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from item to lala") } }
    end

    describe 'for a valid entity name' do
      it 'calls normalize' do
        expect(Entities::SubEntities::PricebookEntryMapper).to receive(:normalize).with({})
        subject.map_to('PricebookEntry', {}, nil)
      end

      it 'calls normalize' do
        expect(Entities::SubEntities::Product2Mapper).to receive(:normalize).with({})
        subject.map_to('Product2', {}, nil)
      end
    end
  end

  describe 'push_entities_to_external_to' do
    context 'for Pricebook entry' do
      let(:organization) { create(:organization) }
      let(:client) { Restforce.new }
      let(:pricebook_id) { 'PR1C3B00K-1D' }
      before {
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(pricebook_id)
        allow(client).to receive(:update!)
      }

      context 'for an update' do
        let!(:idmap) { create(:idmap, organization: organization) }
        it 'gets the standard pricebook id' do
          expect(Entities::Item).to receive(:get_pricebook_id)
          subject.push_entities_to_external_to(client, [{entity: {'price' => 45}, idmap: idmap}], 'PricebookEntry', organization)
        end
      end

      context 'for a creation' do
        let(:connec_id) { '344dr-567d' }
        let(:product_id) { 'AE345TR' }
        let!(:idmap) { create(:idmap, organization: organization, external_id: nil, connec_id: connec_id) }
        let!(:product_idmap) { create(:idmap, organization: organization, connec_id: connec_id, connec_entity: 'item', external_entity: 'product2', external_id: product_id) }

        it 'sets a productID and a pricebookID' do
          expect(client).to receive(:create!).with('PricebookEntry', {'price' => 45, 'Product2Id' => product_id, 'Pricebook2Id' => pricebook_id})
          subject.push_entities_to_external_to(client, [{entity: {'price' => 45}, idmap: idmap}], 'PricebookEntry', organization)
        end
      end

    end
  end
end