require 'spec_helper'

describe Entities::SalesOrder do
  describe 'class methods' do
    subject { Entities::SalesOrder }

    it { expect(subject.connec_entity_name).to eql('sales_order') }
    it { expect(subject.external_entity_name).to eql('Order') }
    it { expect(subject.mapper_class).to eql(Entities::SalesOrder::SalesOrderMapper) }

    it { expect(subject.object_name_from_connec_entity_hash({'title' => 'the title'})).to eql('the title') }
    it { expect(subject.object_name_from_external_entity_hash({'name' => 'the name'})).to eql('the name') }
  end

  describe 'instance methods' do
    subject { Entities::SalesOrder.new }


    describe 'connec_model_to_external_model' do
      let(:organization) { create(:organization) }
      let!(:idmap_item) { create(:idmap, organization: organization, connec_id: 'item_connec_id_id', connec_entity: 'item', external_id: 'item_external_id', external_entity: 'product') }

      let(:connec_hash) {
        {
            title: 'a sales order',
            transaction_number: '123456',
            status: 'DRAFT',
            billing_address: {
                line1: 'line1',
                line2: 'line2',
                city: 'city',
                region: 'region',
                postal_code: 'postal_code',
                country: 'country'
            },
            shipping_address: {
                line1: 'shipping_address.line1',
                line2: 'shipping_address.line2',
                city: 'shipping_address.city',
                region: 'shipping_address.region',
                postal_code: 'shipping_address.postal_code',
                country: 'shipping_address.country'
            },
            transaction_date: Date.new(1985, 9, 17).iso8601,
            lines: [
                {
                    unit_price: {
                        net_amount: 55
                    },
                    quantity: '48',
                    description: 'description',
                    item_id: 'item_connec_id_id'
                }
            ]
        }
      }
      let(:external_hash) {
        {
            name: 'a sales order',
            order_number: '123456',
            financial_status: 'pending',
            billing_address: {
                address1: 'line1',
                address2: 'line2',
                city: 'city',
                province: 'region',
                zip: 'postal_code',
                country_code: 'country'
            },
            shipping_address: {
                address1: 'shipping_address.line1',
                address2: 'shipping_address.line2',
                city: 'shipping_address.city',
                province: 'shipping_address.region',
                zip: 'shipping_address.postal_code',
                country_code: 'shipping_address.country'
            },
            closed_at: Date.new(1985, 9, 17).iso8601,
            line_items: [
                {
                    price: 55,
                    quantity: '48',
                    title: 'description',
                    product_id: 'item_external_id'
                }
            ]
        }
      }

      it { expect(subject.map_to_connec(external_hash.deep_stringify_keys, organization)).to eql(connec_hash) }
      it { expect(subject.map_to_external(connec_hash.deep_stringify_keys, organization)).to eql(external_hash) }
    end

  end
end