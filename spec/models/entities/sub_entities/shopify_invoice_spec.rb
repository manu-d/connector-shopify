require 'spec_helper'

describe Entities::SubEntities::ShopifyInvoice do

  describe 'class methods' do
    subject { Entities::SubEntities::ShopifyInvoice }

    it { expect(subject.entity_name).to eql('Shopify Invoice') }
    it { expect(subject.external?).to eql(true) }
    it { expect(subject.object_name_from_external_entity_hash({'order_id' => 'ABC'})).to eql('ABC') }
    it { expect(subject.last_update_date_from_external_entity_hash({'created_at' => Time.new(1985, 9, 17).iso8601})).to eql(Time.new(1985, 9, 17)) }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::SubEntities::ShopifyInvoice.new(organization, connec_client, external_client, opts) }
    describe 'map_to_connec' do

      let(:transaction) {
        {
            id: 'transaction_id',
            order_id: 'order_id',
            created_at: Time.new(1985, 9, 17).iso8601,
            financial_status: 'pending',
            kind: 'sale',
            currency: 'AUD',
            amount: 55.00,
            customer: {id: 'person_external_id'},
            line_items: [
                {
                    id: 'line_id',
                    price: 55,
                    quantity: '48',
                    title: 'description',
                    variant_id: 'item_id'
                }
            ]
        }.with_indifferent_access
      }


      describe 'invoices' do
        let!(:idmap_item) { create(:idmap, organization: organization, connec_id: 'item_connec_id', connec_entity: 'item', external_id: 'item_external_id', external_entity: 'variant') }


        let(:connec_hash) {
          {
              id: [{id: 'order_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
              sales_order_id: [{id: 'order_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
              transaction_date: Time.new(1985, 9, 17).iso8601,
              person_id: [{id: 'person_external_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
              type: 'CUSTOMER',
              status: 'PAID',
              lines: [
                  {
                      id: [{id: 'line_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
                      unit_price: {
                          net_amount: 55
                      },
                      quantity: '48',
                      description: 'description',
                      item_id: [{id: 'item_id', provider: organization.oauth_provider, realm: organization.oauth_uid}]
                  }
              ]
          }
        }
        it {
          expect(subject.map_to('Invoice', transaction)).to eql(connec_hash.with_indifferent_access)
        }
      end

    end
  end
end


