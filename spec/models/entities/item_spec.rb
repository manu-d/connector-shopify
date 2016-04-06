require 'spec_helper'

describe Entities::Item do
  describe 'class methods' do
    subject { Entities::Item }

    it { expect(subject.connec_entity_name).to eql('Item') }
    it { expect(subject.external_entity_name).to eql('Variant') }
    it { expect(subject.mapper_class).to eql(Entities::Item::ItemMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'name' => 'the name'})).to eql('the name') }
    it { expect(subject.object_name_from_external_entity_hash({'title' => 'the name'})).to eql('the name') }
  end

  describe 'get_external_entities' do
    let(:client) { Object.new }
    before { allow(client).to receive(:find).and_return(entities) }

    context 'when no entities' do
      let(:entities) { [] }

      it 'returns an empty array' do
        expect(subject.get_external_entities(client, nil, nil)).to eq([])
      end
    end
  end

  describe 'instance methods' do
    subject { Entities::Item.new }

    describe 'mapping to connec' do
      let(:external_hash) {
        [
            {
                title: 'red',
                product_title: 'product name',
                body_html: 'product description',
                sku: 'code',
                price: 450,
                inventory_quantity: 12,
                weight: 8,
                weight_unit: 'lb',
                inventory_management: 'shopify'
            },
            {
                title: 'blue',
                product_title: 'product name 2',
                body_html: 'product description 2',
                sku: 'code2',
                price: 555,
                inventory_quantity: 20,
                weight: 1,
                weight_unit: 'kg',
                inventory_management: nil
            }
        ]
      }
      let(:connec_hash) {
        [
            {
                name: 'product name red',
                product_name: 'product name',
                description: 'product description',
                code: 'code',
                sale_price: {
                    net_amount: 450
                },
                quantity_available: 12,
                weight: 8,
                weight_unit: 'lb',
                is_inventoried: true
            },
            {
                name: 'product name 2 blue',
                product_name: 'product name 2',
                description: 'product description 2',
                code: 'code2',
                sale_price: {
                    net_amount: 555
                },
                quantity_available: 20,
                weight: 1,
                weight_unit: 'kg',
                is_inventoried: false
            }
        ]
      }

      it { expect(external_hash.map { |hash| subject.map_to_connec(hash.deep_stringify_keys, nil) }).to eql(connec_hash) }
    end

    describe 'mapping to external' do

      let(:connec_hash) {
        [
            {
                name: 'product name',
                description: 'product description',
                code: 'code',
                sale_price: {
                    net_amount: 450
                },
                quantity_available: 12,
                weight: 8,
                weight_unit: 'lb',
                is_inventoried: true
            },
            {
                name: 'product name 2',
                description: 'product description 2',
                code: 'code2',
                sale_price: {
                    net_amount: 555
                },
                quantity_available: 20,
                weight: 1,
                weight_unit: 'kg',
                is_inventoried: false
            }
        ]
      }
      let(:external_hash) {
        [
            {
                product_title: 'product name',
                body_html: 'product description',
                sku: 'code',
                price: 450,
                inventory_quantity: 12,
                weight: 8,
                weight_unit: 'lb',
                inventory_management: 'shopify'
            },
            {
                product_title: 'product name 2',
                body_html: 'product description 2',
                sku: 'code2',
                price: 555,
                inventory_quantity: 20,
                weight: 1,
                weight_unit: 'kg',
                inventory_management: nil
            }
        ]
      }
      it { expect(connec_hash.map { |hash| subject.map_to_external(hash.deep_stringify_keys, nil) }).to eql(external_hash) }
    end
  end
end