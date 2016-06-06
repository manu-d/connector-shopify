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
    subject { Entities::Item.new(nil, nil, client, nil) }
    context 'when no entities' do
      let(:entities) { [] }

      it 'returns an empty array' do
        expect(subject.get_external_entities(nil)).to eq([])
      end
    end
  end

  describe 'instance methods' do
    let!(:organization) { create(:organization) }
    subject { Entities::Item.new(organization, nil, nil, nil) }

    describe 'mapping to connec' do

      context 'nominal mapping' do

        let(:external_hashes) {
          [
              {
                  id: 'id-red',
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
                  id: 'id-blue',
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
        let(:connec_hashes) {
          [
              {
                  id: [{id: 'id-red', provider: nil, realm: nil}],
                  name: 'product name red',
                  product_name: 'product name',
                  description: 'product description',
                  reference: 'code',
                  sale_price: {
                      net_amount: 450
                  },
                  quantity_available: 12,
                  weight: 8,
                  weight_unit: 'lb',
                  is_inventoried: true
              },
              {
                  id: [{id: 'id-blue', provider: nil, realm: nil}],
                  name: 'product name 2 blue',
                  product_name: 'product name 2',
                  description: 'product description 2',
                  reference: 'code2',
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
        it {
          expect(subject.map_to_connec(external_hashes[0].with_indifferent_access)).to eql(connec_hashes[0].with_indifferent_access)
          expect(subject.map_to_connec(external_hashes[1].with_indifferent_access)).to eql(connec_hashes[1].with_indifferent_access)
        }
      end

      context 'there is not product title' do
        let(:external_hash) {
          {
              title: 'red'
          }
        }
        let(:connec_hash) {
          {
              id: nil,
              name: 'red',
              product_name: '',
              is_inventoried: false
          }
        }

        it { expect(subject.map_to_connec(external_hash.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
      end
    end

    describe 'mapping to external' do

      let(:connec_hashes) {
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
                reference: 'code2',
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
      let(:external_hashes) {
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
      it {
        expect(subject.map_to_external(connec_hashes[0].with_indifferent_access)).to eql(external_hashes[0].with_indifferent_access)
        expect(subject.map_to_external(connec_hashes[1].with_indifferent_access)).to eql(external_hashes[1].with_indifferent_access)
      }

    end
  end
end