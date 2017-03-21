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

  describe 'instance methods' do
    let(:external_client) { Object.new }
    let!(:organization) { create(:organization) }
    subject { Entities::Item.new(organization, nil, external_client, nil) }

    describe 'get_external_entities' do
      before { allow(external_client).to receive(:find).and_return(entities) }

      context 'when no entities' do
        let(:entities) { [] }

        it 'returns an empty array' do
          expect(subject.get_external_entities(nil)).to eql([])
        end
      end

      context 'when entities' do
        let(:product) { {
          'id' => 'id',
          'title' => 'title',
          'body_html' => 'body',
          'updated_at' => product_updated_at,
          'variants' => [variant1]}
        }
        let(:variant1) { {'price' => 123, 'updated_at' => variant_updated_at} }

        let(:complete_variant) {
          {
            'price' => variant1['price'],
            'product_id' => product['id'],
            'product_title' => product['title'],
            'body_html' => product['body_html'],
            'updated_at' => complete_updated_at
          }
        }
        let(:entities) { [product] }

        context 'when product is more recent' do
          let(:product_updated_at) { 1.day.ago }
          let(:variant_updated_at) { 1.month.ago }
          let(:complete_updated_at) { product_updated_at.to_time.iso8601 }

          it 'extracts the products variants' do
            expect(subject.get_external_entities(nil)).to eql([complete_variant])
          end
        end

        context 'when variant is more recent' do
          let(:product_updated_at) { 1.year.ago }
          let(:variant_updated_at) { 1.month.ago }
          let(:complete_updated_at) { variant_updated_at.to_time.iso8601 }

          it 'extracts the products variants' do
            expect(subject.get_external_entities(nil)).to eql([complete_variant])
          end
        end

      end
    end

    describe 'push_entities_to_connec' do
      xit { 'TODO' }
    end

    describe 'push_entity_to_external' do
      xit { 'Better specs here' }

      context 'when no external_id in idmap' do
        let!(:idmap) { create(:idmap, organization: organization, connec_entity: 'item', external_entity: 'variant', external_id: nil) }

        it 'does a call to shopify and handle idmaps' do
          expect(external_client).to receive(:update).and_return({'id' => 'id', 'variants' => [{'id' => 'variant_id'}]})
          expect(subject.push_entity_to_external({idmap: idmap, entity: {}}, 'Variant')).to eql(idmap: idmap)
        end

        it 'does not store an error in the idmap' do
          allow(external_client).to receive(:update).and_return({'id' => 'id', 'variants' => [{'id' => 'variant_id'}]})
          subject.push_entity_to_external({idmap: idmap, entity: {}}, 'Variant')
          expect(idmap.reload.message).to be nil
        end
      end

      context 'when external_id in idmap' do
        let(:external_id) { 'external_id' }
        let!(:idmap) { create(:idmap, organization: organization, connec_entity: 'item', external_entity: 'variant', external_id: external_id) }
        let!(:product_id_map) { create(:idmap, organization: organization, connec_entity: 'Item', external_entity: 'product', connec_id: idmap.connec_id) }

        it 'does calls to shopify' do
          expect(external_client).to receive(:update).twice
          expect(subject.push_entity_to_external({idmap: idmap, entity: {}}, 'Variant')).to eql(nil)
        end

        it 'does not store an error in the idmap' do
          allow(external_client).to receive(:update)
          subject.push_entity_to_external({idmap: idmap, entity: {}}, 'Variant')
          expect(idmap.reload.message).to be nil
        end
      end
    end

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
                  id: [{id: 'id-red', provider: organization.oauth_provider, realm: organization.oauth_uid}],
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
                  id: [{id: 'id-blue', provider: organization.oauth_provider, realm: organization.oauth_uid}],
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
              id: "",
              name: 'red',
              product_name: '',
              is_inventoried: false
          }
        }

        it { expect(subject.map_to_connec(external_hash.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
      end
    end

    describe 'mapping to external' do

      before { allow(ShopifyClient).to receive(:currency).and_return("AUD") }

      let(:connec_hashes) {
        [
            {
                name: 'product name',
                description: 'product description',
                code: 'code',
                sale_price: {
                    net_amount: 450,
                    currency: "AUD"
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
                    net_amount: 555,
                    currency: "AUD"
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
      it 'maps correctly' do
        expect(subject.map_to_external(connec_hashes[0].with_indifferent_access)).to eql(external_hashes[0].with_indifferent_access)
        expect(subject.map_to_external(connec_hashes[1].with_indifferent_access)).to eql(external_hashes[1].with_indifferent_access)
      end

      context 'when currency is not matching' do

        let(:external_no_price) {
          {
              product_title: 'product name',
              body_html: 'product description',
              sku: 'code',
              inventory_quantity: 12,
              weight: 8,
              weight_unit: 'lb',
              inventory_management: 'shopify'
          }
        }

        before do
          allow(ShopifyClient).to receive(:currency).and_return("GBP")
        end

        it 'does not send the price' do

          expect(subject.map_to_external(connec_hashes[0].with_indifferent_access)).to eql(external_no_price.with_indifferent_access)
        end
      end

    end
  end
end
