require 'spec_helper'

describe Entities::SubEntities::Transaction do

  describe 'class methods' do
    subject { Entities::SubEntities::Transaction }

    it { expect(subject.entity_name).to eql('Transaction') }
    it { expect(subject.external?).to eql(true) }
    it { expect(subject.object_name_from_external_entity_hash({'id' => 'ABC'})).to eql('ABC') }
    it { expect(subject.last_update_date_from_external_entity_hash({'created_at' => Time.new(1985, 9, 17).iso8601})).to eql(Time.new(1985, 9, 17)) }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::SubEntities::Transaction.new(organization, connec_client, external_client, opts) }

    describe 'mapping to connec!' do
      let(:transaction) {
        {
            'id' => '1',
            'order_id' => 'N11003',
            'created_at' => '2016-06-12 23:26:26',
            'currency' => 'AUD',
            'amount' => 155.00,
            'customer' => {
                'id' => 'USER-ID'
            },
            "line_items"=>
              [{"id"=>7946635337,
                "variant_id"=>26168316425,
                "title"=>"SHOPIFY Product 0001",
                "quantity"=>1,
                "price"=>"200.00",
                "grams"=>0,
                "sku"=>"",
                "variant_title"=>"S",
                "vendor"=>"maesrano-integration",
                "fulfillment_service"=>"manual",
                "product_id"=>nil,
                "requires_shipping"=>true,
                "taxable"=>true,
                "gift_card"=>false,
                "name"=>"SHOPIFY Product 0001 - S",
                "variant_inventory_management"=>nil,
                "properties"=>[],
                "product_exists"=>false,
                "fulfillable_quantity"=>1,
                "total_discount"=>"0.00",
                "fulfillment_status"=>nil,
                "tax_lines"=>[{"title"=>"VAT", "price"=>"33.33", "rate"=>0.2}]}],
             "shipping_lines"=>[]
        }
      }

      describe 'payment' do
        let(:connec_payment) {
          {
              'id' => [{'id' => '1', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
               'payment_lines'=> [
                   {
                     "id"=>[{"id"=>7946635337, 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                     "unit_price"=>{"net_amount"=>200.0, "tax_rate"=>20.0, "tax_amount"=>33.33},
                     "quantity"=>1,
                     "description"=>"SHOPIFY Product 0001",
                     "item_id"=> [{"id"=>26168316425, 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                     'linked_transactions' => [
                       'id' => [{'id' => 'N11003', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                       'class' => 'Invoice'
                     ]
                   }
                 ],
              # The amount field is read only in Connec! and calculated based on lines
              'amount' => {'currency' => 'AUD'},
              'title' => 'N11003',
              'person_id' => [{'id' => 'USER-ID', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
              'transaction_date' => '2016-06-12 23:26:26',
              'type' => 'CUSTOMER',
              'status' => 'ACTIVE'
           }
        }

        it 'maps to Connec! payment' do
          expect(subject.map_to('Payment', transaction)).to eql(connec_payment)
        end
      end

    end
  end
end
