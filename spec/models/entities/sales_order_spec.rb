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
    let(:organization) { create(:organization) }

    subject { Entities::SalesOrder.new(organization, nil, nil) }

    describe 'external to connec' do

      let(:external_hash) {
        {
            id: 'id',
            name: 'a sales order',
            order_number: '123456',
            financial_status: 'pending',
            customer: {id: 'person_id'},
            billing_address: {
                address1: 'line1',
                province: 'region',
                zip: 'postal_code',
                address2: 'line2',
                city: 'city',
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
                    id: 'line_id',
                    price: 55,
                    quantity: '48',
                    title: 'description',
                    variant_id: 'item_id'
                }
            ]
        }
      }

      let(:connec_hash) {
        {
            id: [{id: 'id', provider: nil, realm: nil}],
            title: 'a sales order',
            transaction_number: '123456',
            status: 'DRAFT',
            person_id: [{id: 'person_id', provider: nil, realm: nil}],
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
                    id: 'line_id',
                    unit_price: {
                        net_amount: 55
                    },
                    quantity: '48',
                    description: 'description',
                    item_id: [{id: 'item_id', provider: nil, realm: nil}]
                }
            ]
        }
      }


      it { expect(subject.map_to_connec(external_hash.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
    end

  end
end