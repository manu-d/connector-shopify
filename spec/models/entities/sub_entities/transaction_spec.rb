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
              'payment_lines'=> [{"amount"=>155.0, "linked_transactions"=>[{"id"=>[{"id"=>"N11003", "provider"=>"this_app", "realm"=>organization.oauth_uid}], "class"=>"Invoice", "applied_amount"=>155.0}]}],
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

        context 'without shipping' do
          let(:transaction) {
            {
              "id"=>5659504008,
              "amount"=>"41.70",
              "kind"=>"sale",
              "gateway"=>"manual",
              "status"=>"success",
              "message"=>"Marked the manual payment as received",
              "created_at"=>"2017-05-26T16:48:43+10:00",
              "test"=>false,
              "authorization"=>nil,
              "currency"=>"AUD",
              "location_id"=>nil,
              "user_id"=>nil,
              "parent_id"=>nil,
              "device_id"=>nil,
              "receipt"=>{

              },
              "error_code"=>nil,
              "source_name"=>"shopify_draft_order",
              "line_items"=>[
                {
                  "id"=>9323051080,
                  "variant_id"=>36815052424,
                  "title"=>"Bacon and Cheese Burger",
                  "quantity"=>1,
                  "price"=>"11.90",
                  "grams"=>0,
                  "sku"=>"BG1044",
                  "variant_title"=>nil,
                  "vendor"=>"contacts-revamp",
                  "fulfillment_service"=>"manual",
                  "product_id"=>9715975752,
                  "requires_shipping"=>false,
                  "taxable"=>true,
                  "gift_card"=>false,
                  "name"=>"Bacon and Cheese Burger",
                  "variant_inventory_management"=>nil,
                  "properties"=>nil,
                  "product_exists"=>true,
                  "fulfillable_quantity"=>1,
                  "total_discount"=>"0.00",
                  "fulfillment_status"=>nil,
                  "tax_lines"=>[
                    {
                      "title"=>"GST",
                      "price"=>"1.08",
                      "rate"=>0.1
                    }
                  ]
                },
                {
                  "id"=>9323051144,
                  "variant_id"=>36814965192,
                  "title"=>"Double Beef Burger",
                  "quantity"=>2,
                  "price"=>"14.90",
                  "grams"=>0,
                  "sku"=>"BG1031",
                  "variant_title"=>nil,
                  "vendor"=>"contacts-revamp",
                  "fulfillment_service"=>"manual",
                  "product_id"=>9715954184,
                  "requires_shipping"=>false,
                  "taxable"=>true,
                  "gift_card"=>false,
                  "name"=>"Double Beef Burger",
                  "variant_inventory_management"=>nil,
                  "properties"=>nil,
                  "product_exists"=>true,
                  "fulfillable_quantity"=>2,
                  "total_discount"=>"0.00",
                  "fulfillment_status"=>nil,
                  "tax_lines"=>[
                    {
                      "title"=>"GST",
                      "price"=>"2.71",
                      "rate"=>0.1
                    }
                  ]
                }
              ],
              "shipping_lines"=>[

              ],
              "order_id"=>4863088456,
              "customer"=>{
                "id"=>5241025160,
                "email"=>"chris@example.com",
                "accepts_marketing"=>false,
                "created_at"=>"2017-05-26T16:13:35+10:00",
                "updated_at"=>"2017-05-26T16:48:43+10:00",
                "first_name"=>"Chris",
                "last_name"=>"Cordial",
                "orders_count"=>3,
                "state"=>"disabled",
                "total_spent"=>"80.40",
                "last_order_id"=>4863088456,
                "note"=>"",
                "verified_email"=>true,
                "multipass_identifier"=>nil,
                "tax_exempt"=>false,
                "phone"=>"+61411245541",
                "tags"=>"",
                "last_order_name"=>"#1006",
                "default_address"=>{
                  "id"=>5537262216,
                  "first_name"=>"Chris",
                  "last_name"=>"Cordial",
                  "company"=>"",
                  "address1"=>"",
                  "address2"=>"",
                  "city"=>"",
                  "province"=>"Australian Capital Territory",
                  "country"=>"Australia",
                  "zip"=>"",
                  "phone"=>"",
                  "name"=>"Chris Cordial",
                  "province_code"=>"ACT",
                  "country_code"=>"AU",
                  "country_name"=>"Australia",
                  "default"=>true
                }
              },
              "transaction_number"=>1006
            }
          }

          let(:connec_payment) {
            {
              "title"=>4863088456,
              "transaction_date"=>"2017-05-26T16:48:43+10:00",
              "person_id"=>[{"id"=>5241025160, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
              "amount"=>{"currency"=>"AUD"},
              "payment_lines" => [
                {"amount"=>41.7, "linked_transactions"=>[{"id"=>[{"id"=>4863088456, "provider"=>"this_app", "realm"=>organization.oauth_uid}], "class"=>"Invoice", "applied_amount"=>41.7}]}
              ],
              "type"=>"CUSTOMER",
              "status"=>"ACTIVE",
              "transaction_number"=>1006,
              "id"=>[{"id"=>"5659504008", "provider"=>"this_app", "realm"=>organization.oauth_uid}]
            }
          }

          it 'maps to Connec! payment' do
            expect(subject.map_to('Payment', transaction)).to eql(connec_payment)
          end
        end
      end
    end
  end
end
