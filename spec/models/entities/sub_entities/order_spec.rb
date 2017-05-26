require 'spec_helper'

describe Entities::SubEntities::Order do
  describe 'class methods' do
    subject { Entities::SubEntities::Order }

    it { expect(subject.entity_name).to eql('Order') }
    it { expect(subject.external?).to eql(true) }
    it { expect(subject.object_name_from_external_entity_hash({'id' => 'ABC'})).to eql('ABC') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { }
    subject { Entities::SubEntities::Order.new(organization, connec_client, external_client, opts) }

    describe 'map_to_connec' do
      let(:order) {
        {
          id: 'id',
          name: 'a sales order',
          order_number: '123456',
          currency: 'EUR',
          financial_status: 'pending',
          customer: {id: 'person_id'},
          taxes_included: false,
          total_price: 82.96,
          total_discounts: 12.06,
          quantity: '1',
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
          shipping_lines: [
            {
              id: "369256396",
              title: "Standard",
              price: 10,
              code: "Free Shipping",
              source: "shopify",
              phone: nil,
              requested_fulfillment_service_id: nil,
              delivery_category: nil,
              carrier_identifier: nil,
              tax_lines: [
              ]
            }
          ],
          created_at: Date.new(1985, 9, 17).iso8601,
          line_items: [
            {
              id: 'line_id',
              price: 55,
              quantity: '1',
              title: 'description',
              variant_id: 'item_id',
              tax_lines: [
                {
                  title: "State Tax",
                  price: "3.98",
                  rate: 0.06
                },
                {
                  title: "Custom Tax",
                  price: "3.98",
                  rate: 0.06
                },
              ]
            }
          ]
        }
      }

      describe 'external to connec' do
        let(:connec_hash) {
          {
            id: [{id: 'id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
            title: 'a sales order',
            transaction_number: '123456',
            status: 'DRAFT',
            type: "CUSTOMER",
            person_id: [{id: 'person_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
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
                id: [{id: 'line_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
                unit_price: {
                    net_amount: 55.0,
                    tax_amount: 7.96,
                    currency: 'EUR'
                },
                quantity: '1',
                description: 'description',
                item_id: [{id: 'item_id', provider: organization.oauth_provider, realm: organization.oauth_uid}]
              },
              {
                id: [{id: '369256396', provider: organization.oauth_provider, realm: organization.oauth_uid}],
                unit_price: {
                    net_amount: 10.0,
                    tax_amount: 0.0,
                    currency: 'EUR'
                },
                description: 'Shipping: Standard',
                quantity: 1
              },
              {
                id: [{id: 'shopify-discount', provider: organization.oauth_provider, realm: organization.oauth_uid}],
                unit_price: {
                    net_amount: -12.06,
                    tax_amount: 0.0,
                    currency: 'EUR'
                },
                description: 'Discount',
                quantity: 1
              }
            ]
          }
        }

        context 'with taxes excluded' do
          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
        end

        context 'with taxes included' do
          before do
            order[:taxes_included] = true
            connec_hash[:lines][0][:unit_price][:total_amount] = 55.0
            connec_hash[:lines][0][:unit_price].delete(:net_amount)
            connec_hash[:lines][0][:unit_price][:tax_amount] = 0.0
          end

          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
        end

        context 'when the order has been paid' do
          before do
            order[:financial_status] = 'paid'
          end

          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.merge({balance: 0.0, deposit: 82.96, status: 'PAID'}).with_indifferent_access) }
        end

        context 'without shipiing' do
          let(:order) {
            {
              "id" => 4862975304,
              "email" => "bob@example.com",
              "closed_at" => "2017-05-26T15:02:15+10:00",
              "created_at" => "2017-05-26T15:02:05+10:00",
              "updated_at" => "2017-05-26T15:02:15+10:00",
              "number" => 2,
              "note" => nil,
              "token" => "e4df38175d275cf7e6c9bc1ccdf5c949",
              "gateway" => "manual",
              "test" => false,
              "total_price" => "29.80",
              "subtotal_price" => "29.80",
              "total_weight" => 0,
              "total_tax" => "2.71",
              "taxes_included" => true,
              "currency" => "AUD",
              "financial_status" => "paid",
              "confirmed" => true,
              "total_discounts" => "0.00",
              "total_line_items_price" => "29.80",
              "cart_token" => nil,
              "buyer_accepts_marketing" => false,
              "name" => "#1002",
              "referring_site" => nil,
              "landing_site" => nil,
              "cancelled_at" => nil,
              "cancel_reason" => nil,
              "total_price_usd" => "22.34",
              "checkout_token" => nil,
              "reference" => nil,
              "user_id" => 118786952,
              "location_id" => nil,
              "source_identifier" => nil,
              "source_url" => nil,
              "processed_at" => "2017-05-26T15:02:05+10:00",
              "device_id" => nil,
              "phone" => nil,
              "browser_ip" => nil,
              "landing_site_ref" => nil,
              "order_number" => 1002,
              "discount_codes" => nil,
              "note_attributes" => nil,
              "payment_gateway_names" => [
                "manual"
              ],
              "processing_method" => "manual",
              "checkout_id" => nil,
              "source_name" => "shopify_draft_order",
              "fulfillment_status" => "fulfilled",
              "tax_lines" => [
                {
                  "title" => "GST",
                  "price" => "2.71",
                  "rate" => 0.1
                }
              ],
              "tags" => "",
              "contact_email" => "bob@example.com",
              "order_status_url" => nil,
              "line_items" => [
                {
                  "id" => 9322852104,
                  "variant_id" => 36814965192,
                  "title" => "Double Beef Burger",
                  "quantity" => 2,
                  "price" => "14.90",
                  "grams" => 0,
                  "sku" => "BG1031",
                  "variant_title" => nil,
                  "vendor" => "contacts-revamp",
                  "fulfillment_service" => "manual",
                  "product_id" => 9715954184,
                  "requires_shipping" => false,
                  "taxable" => true,
                  "gift_card" => false,
                  "name" => "Double Beef Burger",
                  "variant_inventory_management" => nil,
                  "properties" => nil,
                  "product_exists" => true,
                  "fulfillable_quantity" => 0,
                  "total_discount" => "0.00",
                  "fulfillment_status" => "fulfilled",
                  "tax_lines" => [
                    {
                      "title" => "GST",
                      "price" => "2.71",
                      "rate" => 0.1
                    }
                  ]
                }
              ],
              "shipping_lines" => nil,
              "billing_address" => {
                "first_name" => "Bob",
                "address1" => nil,
                "phone" => nil,
                "city" => nil,
                "zip" => nil,
                "province" => "Australian Capital Territory",
                "country" => "Australia",
                "last_name" => "Builder",
                "address2" => nil,
                "company" => nil,
                "latitude" => nil,
                "longitude" => nil,
                "name" => "Bob Builder",
                "country_code" => "AU",
                "province_code" => "ACT"
              },
              "shipping_address" => {
                "first_name" => "Bob",
                "address1" => nil,
                "phone" => nil,
                "city" => nil,
                "zip" => nil,
                "province" => "Australian Capital Territory",
                "country" => "Australia",
                "last_name" => "Builder",
                "address2" => nil,
                "company" => nil,
                "latitude" => nil,
                "longitude" => nil,
                "name" => "Bob Builder",
                "country_code" => "AU",
                "province_code" => "ACT"
              },
              "fulfillments" => [
                {
                  "id" => 4386057096,
                  "order_id" => 4862975304,
                  "status" => "success",
                  "created_at" => "2017-05-26T15:02:15+10:00",
                  "service" => "manual",
                  "updated_at" => "2017-05-26T15:02:15+10:00",
                  "tracking_company" => nil,
                  "shipment_status" => nil,
                  "tracking_number" => nil,
                  "tracking_numbers" => nil,
                  "tracking_url" => nil,
                  "tracking_urls" => nil,
                  "receipt" => {

                  },
                  "line_items" => [
                    {
                      "id" => 9322852104,
                      "variant_id" => 36814965192,
                      "title" => "Double Beef Burger",
                      "quantity" => 2,
                      "price" => "14.90",
                      "grams" => 0,
                      "sku" => "BG1031",
                      "variant_title" => nil,
                      "vendor" => "contacts-revamp",
                      "fulfillment_service" => "manual",
                      "product_id" => 9715954184,
                      "requires_shipping" => false,
                      "taxable" => true,
                      "gift_card" => false,
                      "name" => "Double Beef Burger",
                      "variant_inventory_management" => nil,
                      "properties" => nil,
                      "product_exists" => true,
                      "fulfillable_quantity" => 0,
                      "total_discount" => "0.00",
                      "fulfillment_status" => "fulfilled",
                      "tax_lines" => [
                        {
                          "title" => "GST",
                          "price" => "2.71",
                          "rate" => 0.1
                        }
                      ]
                    }
                  ]
                }
              ],
              "refunds" => nil,
              "customer" => {
                "id" => 5240854216,
                "email" => "bob@example.com",
                "accepts_marketing" => false,
                "created_at" => "2017-05-26T14:30:57+10:00",
                "updated_at" => "2017-05-26T15:02:06+10:00",
                "first_name" => "Bob",
                "last_name" => "Builder",
                "orders_count" => 1,
                "state" => "disabled",
                "total_spent" => "29.80",
                "last_order_id" => 4862975304,
                "note" => "",
                "verified_email" => true,
                "multipass_identifier" => nil,
                "tax_exempt" => false,
                "phone" => nil,
                "tags" => "",
                "last_order_name" => "#1002",
                "default_address" => {
                  "id" => 5537088264,
                  "first_name" => "Bob",
                  "last_name" => "Builder",
                  "company" => "",
                  "address1" => "",
                  "address2" => "",
                  "city" => "",
                  "province" => "Australian Capital Territory",
                  "country" => "Australia",
                  "zip" => "",
                  "phone" => "",
                  "name" => "Bob Builder",
                  "province_code" => "ACT",
                  "country_code" => "AU",
                  "country_name" => "Australia",
                  "default" => true
                }
              },
              "entity" => "orders",
              "org_uid" => "cld-94oc",
              "webhook" => {
                "id" => 4862975304,
                "email" => "bob@example.com",
                "closed_at" => "2017-05-26T15:02:15+10:00",
                "created_at" => "2017-05-26T15:02:05+10:00",
                "updated_at" => "2017-05-26T15:02:15+10:00",
                "number" => 2,
                "note" => nil,
                "token" => "e4df38175d275cf7e6c9bc1ccdf5c949",
                "gateway" => "manual",
                "test" => false,
                "total_price" => "29.80",
                "subtotal_price" => "29.80",
                "total_weight" => 0,
                "total_tax" => "2.71",
                "taxes_included" => true,
                "currency" => "AUD",
                "financial_status" => "paid",
                "confirmed" => true,
                "total_discounts" => "0.00",
                "total_line_items_price" => "29.80",
                "cart_token" => nil,
                "buyer_accepts_marketing" => false,
                "name" => "#1002",
                "referring_site" => nil,
                "landing_site" => nil,
                "cancelled_at" => nil,
                "cancel_reason" => nil,
                "total_price_usd" => "22.34",
                "checkout_token" => nil,
                "reference" => nil,
                "user_id" => 118786952,
                "location_id" => nil,
                "source_identifier" => nil,
                "source_url" => nil,
                "processed_at" => "2017-05-26T15:02:05+10:00",
                "device_id" => nil,
                "phone" => nil,
                "browser_ip" => nil,
                "landing_site_ref" => nil,
                "order_number" => 1002,
                "discount_codes" => nil,
                "note_attributes" => nil,
                "payment_gateway_names" => [
                  "manual"
                ],
                "processing_method" => "manual",
                "checkout_id" => nil,
                "source_name" => "shopify_draft_order",
                "fulfillment_status" => "fulfilled",
                "tax_lines" => [
                  {
                    "title" => "GST",
                    "price" => "2.71",
                    "rate" => 0.1
                  }
                ],
                "tags" => "",
                "contact_email" => "bob@example.com",
                "order_status_url" => nil,
                "line_items" => [
                  {
                    "id" => 9322852104,
                    "variant_id" => 36814965192,
                    "title" => "Double Beef Burger",
                    "quantity" => 2,
                    "price" => "14.90",
                    "grams" => 0,
                    "sku" => "BG1031",
                    "variant_title" => nil,
                    "vendor" => "contacts-revamp",
                    "fulfillment_service" => "manual",
                    "product_id" => 9715954184,
                    "requires_shipping" => false,
                    "taxable" => true,
                    "gift_card" => false,
                    "name" => "Double Beef Burger",
                    "variant_inventory_management" => nil,
                    "properties" => nil,
                    "product_exists" => true,
                    "fulfillable_quantity" => 0,
                    "total_discount" => "0.00",
                    "fulfillment_status" => "fulfilled",
                    "tax_lines" => [
                      {
                        "title" => "GST",
                        "price" => "2.71",
                        "rate" => 0.1
                      }
                    ]
                  }
                ],
                "shipping_lines" => nil,
                "billing_address" => {
                  "first_name" => "Bob",
                  "address1" => nil,
                  "phone" => nil,
                  "city" => nil,
                  "zip" => nil,
                  "province" => "Australian Capital Territory",
                  "country" => "Australia",
                  "last_name" => "Builder",
                  "address2" => nil,
                  "company" => nil,
                  "latitude" => nil,
                  "longitude" => nil,
                  "name" => "Bob Builder",
                  "country_code" => "AU",
                  "province_code" => "ACT"
                },
                "shipping_address" => {
                  "first_name" => "Bob",
                  "address1" => nil,
                  "phone" => nil,
                  "city" => nil,
                  "zip" => nil,
                  "province" => "Australian Capital Territory",
                  "country" => "Australia",
                  "last_name" => "Builder",
                  "address2" => nil,
                  "company" => nil,
                  "latitude" => nil,
                  "longitude" => nil,
                  "name" => "Bob Builder",
                  "country_code" => "AU",
                  "province_code" => "ACT"
                },
                "fulfillments" => [
                  {
                    "id" => 4386057096,
                    "order_id" => 4862975304,
                    "status" => "success",
                    "created_at" => "2017-05-26T15:02:15+10:00",
                    "service" => "manual",
                    "updated_at" => "2017-05-26T15:02:15+10:00",
                    "tracking_company" => nil,
                    "shipment_status" => nil,
                    "tracking_number" => nil,
                    "tracking_numbers" => nil,
                    "tracking_url" => nil,
                    "tracking_urls" => nil,
                    "receipt" => {

                    },
                    "line_items" => [
                      {
                        "id" => 9322852104,
                        "variant_id" => 36814965192,
                        "title" => "Double Beef Burger",
                        "quantity" => 2,
                        "price" => "14.90",
                        "grams" => 0,
                        "sku" => "BG1031",
                        "variant_title" => nil,
                        "vendor" => "contacts-revamp",
                        "fulfillment_service" => "manual",
                        "product_id" => 9715954184,
                        "requires_shipping" => false,
                        "taxable" => true,
                        "gift_card" => false,
                        "name" => "Double Beef Burger",
                        "variant_inventory_management" => nil,
                        "properties" => nil,
                        "product_exists" => true,
                        "fulfillable_quantity" => 0,
                        "total_discount" => "0.00",
                        "fulfillment_status" => "fulfilled",
                        "tax_lines" => [
                          {
                            "title" => "GST",
                            "price" => "2.71",
                            "rate" => 0.1
                          }
                        ]
                      }
                    ]
                  }
                ],
                "refunds" => nil,
                "customer" => {
                  "id" => 5240854216,
                  "email" => "bob@example.com",
                  "accepts_marketing" => false,
                  "created_at" => "2017-05-26T14:30:57+10:00",
                  "updated_at" => "2017-05-26T15:02:06+10:00",
                  "first_name" => "Bob",
                  "last_name" => "Builder",
                  "orders_count" => 1,
                  "state" => "disabled",
                  "total_spent" => "29.80",
                  "last_order_id" => 4862975304,
                  "note" => "",
                  "verified_email" => true,
                  "multipass_identifier" => nil,
                  "tax_exempt" => false,
                  "phone" => nil,
                  "tags" => "",
                  "last_order_name" => "#1002",
                  "default_address" => {
                    "id" => 5537088264,
                    "first_name" => "Bob",
                    "last_name" => "Builder",
                    "company" => "",
                    "address1" => "",
                    "address2" => "",
                    "city" => "",
                    "province" => "Australian Capital Territory",
                    "country" => "Australia",
                    "zip" => "",
                    "phone" => "",
                    "name" => "Bob Builder",
                    "province_code" => "ACT",
                    "country_code" => "AU",
                    "country_name" => "Australia",
                    "default" => true
                  }
                }
              },
              "transactions" => [
                {
                  "id" => 5659367432,
                  "amount" => "29.80",
                  "kind" => "sale",
                  "gateway" => "manual",
                  "status" => "success",
                  "message" => "Marked the manual payment as received",
                  "created_at" => "2017-05-26T15:02:05+10:00",
                  "test" => false,
                  "authorization" => nil,
                  "currency" => "AUD",
                  "location_id" => nil,
                  "user_id" => nil,
                  "parent_id" => nil,
                  "device_id" => nil,
                  "receipt" => {

                  },
                  "error_code" => nil,
                  "source_name" => "shopify_draft_order",
                  "line_items" => [
                    {
                      "id" => 9322852104,
                      "variant_id" => 36814965192,
                      "title" => "Double Beef Burger",
                      "quantity" => 2,
                      "price" => "14.90",
                      "grams" => 0,
                      "sku" => "BG1031",
                      "variant_title" => nil,
                      "vendor" => "contacts-revamp",
                      "fulfillment_service" => "manual",
                      "product_id" => 9715954184,
                      "requires_shipping" => false,
                      "taxable" => true,
                      "gift_card" => false,
                      "name" => "Double Beef Burger",
                      "variant_inventory_management" => nil,
                      "properties" => nil,
                      "product_exists" => true,
                      "fulfillable_quantity" => 0,
                      "total_discount" => "0.00",
                      "fulfillment_status" => "fulfilled",
                      "tax_lines" => [
                        {
                          "title" => "GST",
                          "price" => "2.71",
                          "rate" => 0.1
                        }
                      ]
                    }
                  ],
                  "shipping_lines" => [

                  ],
                  "order_id" => 4862975304,
                  "customer" => {
                    "id" => 5240854216,
                    "email" => "bob@example.com",
                    "accepts_marketing" => false,
                    "created_at" => "2017-05-26T14:30:57+10:00",
                    "updated_at" => "2017-05-26T15:02:06+10:00",
                    "first_name" => "Bob",
                    "last_name" => "Builder",
                    "orders_count" => 1,
                    "state" => "disabled",
                    "total_spent" => "29.80",
                    "last_order_id" => 4862975304,
                    "note" => "",
                    "verified_email" => true,
                    "multipass_identifier" => nil,
                    "tax_exempt" => false,
                    "phone" => nil,
                    "tags" => "",
                    "last_order_name" => "#1002",
                    "default_address" => {
                      "id" => 5537088264,
                      "first_name" => "Bob",
                      "last_name" => "Builder",
                      "company" => "",
                      "address1" => "",
                      "address2" => "",
                      "city" => "",
                      "province" => "Australian Capital Territory",
                      "country" => "Australia",
                      "zip" => "",
                      "phone" => "",
                      "name" => "Bob Builder",
                      "province_code" => "ACT",
                      "country_code" => "AU",
                      "country_name" => "Australia",
                      "default" => true
                    }
                  },
                  "transaction_number" => 1002
                }
              ]
            }
          }

          let(:connec_hash) {
            {
              "person_id"=>[{"id"=>5240854216, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
              "transaction_date"=>"2017-05-26T15:02:05+10:00",
              "transaction_number"=>1002,
              "title"=>"#1002",
              "shipping_address"=>{
                "region"=>"Australian Capital Territory",
                "country"=>"AU"
              },
              "billing_address"=>{
                "region"=>"Australian Capital Territory",
                "country"=>"AU"
              },
              "lines"=>[
                {
                  "id"=>[{"id"=>9322852104, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
                  "unit_price"=>{
                    "total_amount"=>14.9,
                    "tax_amount"=>0.0,
                    "currency"=>"AUD"
                  },
                  "quantity"=>2,
                  "description"=>"Double Beef Burger",
                  "item_id"=>[{"id"=>36814965192, "provider"=>"this_app", "realm"=>organization.oauth_uid}
                  ]
                }
              ],
              "status"=>"PAID",
              "type"=>"CUSTOMER",
              "balance"=>0.0,
              "deposit"=>29.8,
              "id"=>[{"id"=>"4862975304", "provider"=>"this_app", "realm"=>organization.oauth_uid}
              ]
            }
          }

          it 'maps into a connec invoice' do
            expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash)
          end
        end
      end
    end

    describe 'get_external_entities' do
      let(:orders) { [
          {
              'id' => 'order_id_1',
              'line_items' => [{'id' => 'line_item_1'}, {'id' => 'line_item_2'}],
              'shipping_lines' => [{'id' => 'shipping_line_item_1'}, {'id' => 'shipping_line_item_2'}],
              'customer' => {'id' => 'c1'},
              'order_number' => '1001'
          }, {
              'id' => 'order_id_2',
              'line_items' => [{'id' => 'line_item_3'}, {'id' => 'line_item_4'}],
              'customer' => {'id' => 'c2'},
              'order_number' => '1002'
          }
      ] }
      let(:transactions) { {
          'order_id_1' => [{'id' => 'transactions_1'}, {'id' => 'transactions_2'}],
          'order_id_2' => [{'id' => 'transactions_3'}, {'id' => 'transactions_4'}]
      }
      }
      let(:expected_orders) {
        [
            {
                'id' => 'order_id_1',
                'line_items' => [{'id' => 'line_item_1'}, {'id' => 'line_item_2'}],
                "shipping_lines"=> [{"id"=>"shipping_line_item_1"}, {"id"=>"shipping_line_item_2"}],
                'customer' => {'id' => 'c1'},
                'order_number'=>'1001',
                'transactions' => [
                    {'id' => 'transactions_1', 'order_id' => 'order_id_1', 'transaction_number' => '1001', 'line_items' => [{'id' => 'line_item_1'}, {'id' => 'line_item_2'}], 'shipping_lines' => [{"id"=>"shipping_line_item_1"}, {"id"=>"shipping_line_item_2"}],
                     'customer' => {'id' => 'c1'}},
                    {'id' => 'transactions_2', 'order_id' => 'order_id_1', 'transaction_number' => '1001','line_items' => [{'id' => 'line_item_1'}, {'id' => 'line_item_2'}], 'shipping_lines' => [{"id"=>"shipping_line_item_1"}, {"id"=>"shipping_line_item_2"}],
                     'customer' => {'id' => 'c1'}}
                ]
            }, {
                'id' => 'order_id_2',
                'line_items' => [{'id' => 'line_item_3'}, {'id' => 'line_item_4'}],
                'customer' => {'id' => 'c2'},
                'order_number'=>'1002',
                'transactions' => [
                    {'id' => 'transactions_3', 'order_id' => 'order_id_2', 'transaction_number' => '1002', 'line_items' => [{'id' => 'line_item_3'}, {'id' => 'line_item_4'}], "shipping_lines"=> [], 'customer' => {'id' => 'c2'}},
                    {'id' => 'transactions_4', 'order_id' => 'order_id_2', 'transaction_number' => '1002', 'line_items' => [{'id' => 'line_item_3'}, {'id' => 'line_item_4'}], "shipping_lines"=> [], 'customer' => {'id' => 'c2'}}
                ]
            }
        ]
      }


      it 'returns the entities' do
        allow(external_client).to receive(:find).with('Order').and_return(orders)
        allow(external_client).to receive(:find).with('Transaction', {:order_id => 'order_id_1'}).and_return(transactions['order_id_1'])
        allow(external_client).to receive(:find).with('Transaction', {:order_id => 'order_id_2'}).and_return(transactions['order_id_2'])
        expect(subject.get_external_entities('Orders')).to eql(expected_orders)
      end
    end
  end
end
