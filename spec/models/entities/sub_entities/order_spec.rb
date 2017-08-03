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
    let(:opts) { {shipping_tax_rates: [
          {
            "name"=>"United Kingdom",
            "tax"=>0.2,
            # This would be a country code with real data
            "code"=>"shipping_address.country",
          },
          {
            "name"=>"Rest of World",
            "tax"=>0.0,
            "code"=>"*"
          }
        ]
      }
    }
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
            opts: {sparse: false},
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
            apply_tax_after_discount: false,
            transaction_date: Date.new(1985, 9, 17).iso8601,
            lines: [
              {
                id: [{id: 'line_id', provider: organization.oauth_provider, realm: organization.oauth_uid}],
                unit_price: {
                    net_amount: 55.0,
                    tax_rate: 12.0,
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
                    tax_rate: 20.0,
                    currency: 'EUR'
                },
                description: 'Shipping: Standard',
                quantity: 1
              }
            ]
          }
        }

        context 'with taxes excluded' do
          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.merge(apply_tax_after_discount: true).with_indifferent_access) }
        end

        context 'with taxes included' do
          before do
            order[:taxes_included] = true
            connec_hash[:lines][0][:unit_price][:total_amount] = 55.0
            connec_hash[:lines][0][:unit_price].delete(:net_amount)
            connec_hash[:lines][1][:unit_price][:total_amount] = 10.0
            connec_hash[:lines][1][:unit_price].delete(:net_amount)
          end

          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.with_indifferent_access) }
        end

        context 'when the order has been paid' do
          before do
            order[:financial_status] = 'paid'
          end

          it { expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash.merge({balance: 0.0, deposit: 82.96, status: 'PAID', apply_tax_after_discount: true}).with_indifferent_access) }
        end

        context 'with shipping and global discount' do
          let(:order) {
            {
              "id"=>4870612872,
              "email"=>"alice@example.com",
              "closed_at"=>nil,
              "created_at"=>"2017-05-29T09:44:56+10:00",
              "updated_at"=>"2017-05-29T09:44:56+10:00",
              "number"=>9,
              "note"=>nil,
              "token"=>"59444824a9a9a84b9f0fff22c5cc40a8",
              "gateway"=>"manual",
              "test"=>false,
              "total_price"=>"26.42",
              "subtotal_price"=>"21.42",
              "total_weight"=>0,
              "total_tax"=>"1.95",
              "taxes_included"=>true,
              "currency"=>"AUD",
              "financial_status"=>"paid",
              "confirmed"=>true,
              "total_discounts"=>"2.38",
              "total_line_items_price"=>"23.80",
              "cart_token"=>nil,
              "buyer_accepts_marketing"=>false,
              "name"=>"#1009",
              "referring_site"=>nil,
              "landing_site"=>nil,
              "cancelled_at"=>nil,
              "cancel_reason"=>nil,
              "total_price_usd"=>"19.68",
              "checkout_token"=>nil,
              "reference"=>nil,
              "user_id"=>118786952,
              "location_id"=>nil,
              "source_identifier"=>nil,
              "source_url"=>nil,
              "processed_at"=>"2017-05-29T09:44:56+10:00",
              "device_id"=>nil,
              "phone"=>nil,
              "browser_ip"=>nil,
              "landing_site_ref"=>nil,
              "order_number"=>1009,
              "discount_codes"=>[
                {
                  "code"=>"Global Discount",
                  "amount"=>"2.38",
                  "type"=>"percentage"
                }
              ],
              "note_attributes"=>nil,
              "payment_gateway_names"=>[
                "manual"
              ],
              "processing_method"=>"manual",
              "checkout_id"=>nil,
              "source_name"=>"shopify_draft_order",
              "fulfillment_status"=>nil,
              "tax_lines"=>[
                {
                  "title"=>"GST",
                  "price"=>"1.95",
                  "rate"=>0.1
                }
              ],
              "tags"=>"",
              "contact_email"=>"alice@example.com",
              "order_status_url"=>nil,
              "line_items"=>[
                {
                  "id"=>9335880968,
                  "variant_id"=>36815052424,
                  "title"=>"Bacon and Cheese Burger",
                  "quantity"=>2,
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
                  "fulfillable_quantity"=>2,
                  "total_discount"=>"0.00",
                  "fulfillment_status"=>nil,
                  "tax_lines"=>[
                    {
                      "title"=>"GST",
                      "price"=>"1.95",
                      "rate"=>0.1
                    }
                  ]
                }
              ],
              "shipping_lines"=>[
                {
                  "id"=>4051029064,
                  "title"=>"Deliveroo",
                  "price"=>"5.00",
                  "code"=>"custom",
                  "source"=>"shopify",
                  "phone"=>nil,
                  "requested_fulfillment_service_id"=>nil,
                  "delivery_category"=>nil,
                  "carrier_identifier"=>nil,
                  "tax_lines"=>nil
                }
              ],
              "billing_address"=>{
                "first_name"=>"Alice",
                "address1"=>nil,
                "phone"=>nil,
                "city"=>"Sydney",
                "zip"=>"2000",
                "province"=>"New South Wales",
                "country"=>"Australia",
                "last_name"=>"Arthon",
                "address2"=>nil,
                "company"=>nil,
                "latitude"=>-33.8708464,
                "longitude"=>151.20733,
                "name"=>"Alice Arthon",
                "country_code"=>"AU",
                "province_code"=>"NSW"
              },
              "shipping_address"=>{
                "first_name"=>"Alice",
                "address1"=>nil,
                "phone"=>nil,
                "city"=>"Sydney",
                "zip"=>"2000",
                "province"=>"New South Wales",
                "country"=>"Australia",
                "last_name"=>"Arthon",
                "address2"=>nil,
                "company"=>nil,
                "latitude"=>-33.8708464,
                "longitude"=>151.20733,
                "name"=>"Alice Arthon",
                "country_code"=>"shipping_address.country",
                "province_code"=>"NSW"
              },
              "fulfillments"=>nil,
              "refunds"=>nil,
              "customer"=>{
                "id"=>5240853704,
                "email"=>"alice@example.com",
                "accepts_marketing"=>false,
                "created_at"=>"2017-05-26T14:30:40+10:00",
                "updated_at"=>"2017-05-29T09:44:56+10:00",
                "first_name"=>"Alice",
                "last_name"=>"Arthon",
                "orders_count"=>4,
                "state"=>"disabled",
                "total_spent"=>"62.12",
                "last_order_id"=>4870612872,
                "note"=>"",
                "verified_email"=>true,
                "multipass_identifier"=>nil,
                "tax_exempt"=>false,
                "phone"=>"+61456892312",
                "tags"=>"",
                "last_order_name"=>"#1009",
                "default_address"=>{
                  "id"=>5537087752,
                  "first_name"=>"Alice",
                  "last_name"=>"Arthon",
                  "company"=>"",
                  "address1"=>"",
                  "address2"=>"",
                  "city"=>"Sydney",
                  "province"=>"New South Wales",
                  "country"=>"Australia",
                  "zip"=>"2000",
                  "phone"=>"",
                  "name"=>"Alice Arthon",
                  "province_code"=>"NSW",
                  "country_code"=>"AU",
                  "country_name"=>"Australia",
                  "default"=>true
                }
              },
              "entity"=>"orders",
              "type"=>"update",
              "org_uid"=>"cld-94oc",
              "webhook"=>{
                "id"=>4870612872,
                "email"=>"alice@example.com",
                "closed_at"=>nil,
                "created_at"=>"2017-05-29T09:44:56+10:00",
                "updated_at"=>"2017-05-29T09:44:56+10:00",
                "number"=>9,
                "note"=>nil,
                "token"=>"59444824a9a9a84b9f0fff22c5cc40a8",
                "gateway"=>"manual",
                "test"=>false,
                "total_price"=>"26.42",
                "subtotal_price"=>"21.42",
                "total_weight"=>0,
                "total_tax"=>"1.95",
                "taxes_included"=>true,
                "currency"=>"AUD",
                "financial_status"=>"paid",
                "confirmed"=>true,
                "total_discounts"=>"2.38",
                "total_line_items_price"=>"23.80",
                "cart_token"=>nil,
                "buyer_accepts_marketing"=>false,
                "name"=>"#1009",
                "referring_site"=>nil,
                "landing_site"=>nil,
                "cancelled_at"=>nil,
                "cancel_reason"=>nil,
                "total_price_usd"=>"19.68",
                "checkout_token"=>nil,
                "reference"=>nil,
                "user_id"=>118786952,
                "location_id"=>nil,
                "source_identifier"=>nil,
                "source_url"=>nil,
                "processed_at"=>"2017-05-29T09:44:56+10:00",
                "device_id"=>nil,
                "phone"=>nil,
                "browser_ip"=>nil,
                "landing_site_ref"=>nil,
                "order_number"=>1009,
                "discount_codes"=>[
                  {
                    "code"=>"Global Discount",
                    "amount"=>"2.38",
                    "type"=>"percentage"
                  }
                ],
                "note_attributes"=>nil,
                "payment_gateway_names"=>[
                  "manual"
                ],
                "processing_method"=>"manual",
                "checkout_id"=>nil,
                "source_name"=>"shopify_draft_order",
                "fulfillment_status"=>nil,
                "tax_lines"=>[
                  {
                    "title"=>"GST",
                    "price"=>"1.95",
                    "rate"=>0.1
                  }
                ],
                "tags"=>"",
                "contact_email"=>"alice@example.com",
                "order_status_url"=>nil,
                "line_items"=>[
                  {
                    "id"=>9335880968,
                    "variant_id"=>36815052424,
                    "title"=>"Bacon and Cheese Burger",
                    "quantity"=>2,
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
                    "fulfillable_quantity"=>2,
                    "total_discount"=>"0.00",
                    "fulfillment_status"=>nil,
                    "tax_lines"=>[
                      {
                        "title"=>"GST",
                        "price"=>"1.95",
                        "rate"=>0.1
                      }
                    ]
                  }
                ],
                "shipping_lines"=>[
                  {
                    "id"=>4051029064,
                    "title"=>"Deliveroo",
                    "price"=>"5.00",
                    "code"=>"custom",
                    "source"=>"shopify",
                    "phone"=>nil,
                    "requested_fulfillment_service_id"=>nil,
                    "delivery_category"=>nil,
                    "carrier_identifier"=>nil,
                    "tax_lines"=>nil
                  }
                ],
                "billing_address"=>{
                  "first_name"=>"Alice",
                  "address1"=>nil,
                  "phone"=>nil,
                  "city"=>"Sydney",
                  "zip"=>"2000",
                  "province"=>"New South Wales",
                  "country"=>"Australia",
                  "last_name"=>"Arthon",
                  "address2"=>nil,
                  "company"=>nil,
                  "latitude"=>-33.8708464,
                  "longitude"=>151.20733,
                  "name"=>"Alice Arthon",
                  "country_code"=>"AU",
                  "province_code"=>"NSW"
                },
                "shipping_address"=>{
                  "first_name"=>"Alice",
                  "address1"=>nil,
                  "phone"=>nil,
                  "city"=>"Sydney",
                  "zip"=>"2000",
                  "province"=>"New South Wales",
                  "country"=>"Australia",
                  "last_name"=>"Arthon",
                  "address2"=>nil,
                  "company"=>nil,
                  "latitude"=>-33.8708464,
                  "longitude"=>151.20733,
                  "name"=>"Alice Arthon",
                  "country_code"=>"AU",
                  "province_code"=>"NSW"
                },
                "fulfillments"=>nil,
                "refunds"=>nil,
                "customer"=>{
                  "id"=>5240853704,
                  "email"=>"alice@example.com",
                  "accepts_marketing"=>false,
                  "created_at"=>"2017-05-26T14:30:40+10:00",
                  "updated_at"=>"2017-05-29T09:44:56+10:00",
                  "first_name"=>"Alice",
                  "last_name"=>"Arthon",
                  "orders_count"=>4,
                  "state"=>"disabled",
                  "total_spent"=>"62.12",
                  "last_order_id"=>4870612872,
                  "note"=>"",
                  "verified_email"=>true,
                  "multipass_identifier"=>nil,
                  "tax_exempt"=>false,
                  "phone"=>"+61456892312",
                  "tags"=>"",
                  "last_order_name"=>"#1009",
                  "default_address"=>{
                    "id"=>5537087752,
                    "first_name"=>"Alice",
                    "last_name"=>"Arthon",
                    "company"=>"",
                    "address1"=>"",
                    "address2"=>"",
                    "city"=>"Sydney",
                    "province"=>"New South Wales",
                    "country"=>"Australia",
                    "zip"=>"2000",
                    "phone"=>"",
                    "name"=>"Alice Arthon",
                    "province_code"=>"NSW",
                    "country_code"=>"AU",
                    "country_name"=>"Australia",
                    "default"=>true
                  }
                }
              }
            }
          }

          let(:connec_hash) {
            {
              'opts' => {'sparse' => false},
              "person_id"=>[{"id"=>5240853704, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
              "transaction_date"=>"2017-05-29T09:44:56+10:00",
              "transaction_number"=>1009,
              "title"=>"#1009",
              "shipping_address"=>{
                "city"=>"Sydney",
                "region"=>"New South Wales",
                "postal_code"=>"2000",
                "country"=>"shipping_address.country"
              },
              "apply_tax_after_discount" => false,
              "billing_address"=>{
                "city"=>"Sydney",
                "region"=>"New South Wales",
                "postal_code"=>"2000",
                "country"=>"AU"
              },
              "lines"=>[
                {
                  "id"=>[{"id"=>9335880968, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
                  "unit_price"=>{
                    "total_amount"=>11.9,
                    "tax_rate"=>10.0,
                    "currency"=>"AUD"
                  },
                  "quantity"=>2,
                  "description"=>"Bacon and Cheese Burger",
                  "item_id"=>[{"id"=>36815052424, "provider"=>"this_app", "realm"=>organization.oauth_uid}
                  ]
                },
                {
                  "id"=>[{"id"=>4051029064, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
                  "unit_price"=>{
                    "total_amount"=>5.0,
                    "tax_rate"=>20.0,
                    "currency"=>"AUD"
                  },
                  "description"=>"Shipping: Deliveroo",
                  "quantity"=>1
                }
              ],
              "status"=>"PAID",
              "type"=>"CUSTOMER",
              "balance"=>0.0,
              "deposit"=>26.42,
              "discount_amount" => 2.38,
              "id"=>[{"id"=>"4870612872", "provider"=>"this_app", "realm"=>organization.oauth_uid}
              ]
            }
          }

          it 'maps into a connec invoice' do
            expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash)
          end
        end
      end

      context 'with shipping and line discount' do
        let(:order) {
          {
            "id"=>4870678024,
            "email"=>"chris@example.com",
            "closed_at"=>nil,
            "created_at"=>"2017-05-29T10:19:19+10:00",
            "updated_at"=>"2017-05-29T10:19:19+10:00",
            "number"=>11,
            "note"=>nil,
            "token"=>"be1113c5213e51771dacc2d5dccecbac",
            "gateway"=>"manual",
            "test"=>false,
            "total_price"=>"18.41",
            "subtotal_price"=>"13.41",
            "total_weight"=>0,
            "total_tax"=>"1.22",
            "taxes_included"=>true,
            "currency"=>"AUD",
            "financial_status"=>"paid",
            "confirmed"=>true,
            "total_discounts"=>"1.49",
            "total_line_items_price"=>"14.90",
            "cart_token"=>nil,
            "buyer_accepts_marketing"=>false,
            "name"=>"#1011",
            "referring_site"=>nil,
            "landing_site"=>nil,
            "cancelled_at"=>nil,
            "cancel_reason"=>nil,
            "total_price_usd"=>"13.71",
            "checkout_token"=>nil,
            "reference"=>nil,
            "user_id"=>118786952,
            "location_id"=>nil,
            "source_identifier"=>nil,
            "source_url"=>nil,
            "processed_at"=>"2017-05-29T10:19:19+10:00",
            "device_id"=>nil,
            "phone"=>nil,
            "browser_ip"=>nil,
            "landing_site_ref"=>nil,
            "order_number"=>1011,
            "discount_codes"=>nil,
            "note_attributes"=>nil,
            "payment_gateway_names"=>[
              "manual"
            ],
            "processing_method"=>"manual",
            "checkout_id"=>nil,
            "source_name"=>"shopify_draft_order",
            "fulfillment_status"=>nil,
            "tax_lines"=>[
              {
                "title"=>"GST",
                "price"=>"1.22",
                "rate"=>0.1
              }
            ],
            "tags"=>"",
            "contact_email"=>"chris@example.com",
            "order_status_url"=>nil,
            "line_items"=>[
              {
                "id"=>9335992904,
                "variant_id"=>36814965192,
                "title"=>"Double Beef Burger",
                "quantity"=>1,
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
                "fulfillable_quantity"=>1,
                "total_discount"=>"1.49",
                "fulfillment_status"=>nil,
                "tax_lines"=>[
                  {
                    "title"=>"GST",
                    "price"=>"1.22",
                    "rate"=>0.1
                  }
                ]
              }
            ],
            "shipping_lines"=>[
              {
                "id"=>4051086472,
                "title"=>"Delivery",
                "price"=>"5.00",
                "code"=>"custom",
                "source"=>"shopify",
                "phone"=>nil,
                "requested_fulfillment_service_id"=>nil,
                "delivery_category"=>nil,
                "carrier_identifier"=>nil,
                "tax_lines"=>nil
              }
            ],
            "billing_address"=>{
              "first_name"=>"Chris",
              "address1"=>nil,
              "phone"=>nil,
              "city"=>nil,
              "zip"=>nil,
              "province"=>"Australian Capital Territory",
              "country"=>"Australia",
              "last_name"=>"Cordial",
              "address2"=>nil,
              "company"=>nil,
              "latitude"=>nil,
              "longitude"=>nil,
              "name"=>"Chris Cordial",
              "country_code"=>"AU",
              "province_code"=>"ACT"
            },
            "shipping_address"=>{
              "first_name"=>"Chris",
              "address1"=>nil,
              "phone"=>nil,
              "city"=>nil,
              "zip"=>nil,
              "province"=>"Australian Capital Territory",
              "country"=>"Australia",
              "last_name"=>"Cordial",
              "address2"=>nil,
              "company"=>nil,
              "latitude"=>nil,
              "longitude"=>nil,
              "name"=>"Chris Cordial",
              "country_code"=>"shipping_address.country",
              "province_code"=>"ACT"
            },
            "fulfillments"=>nil,
            "refunds"=>nil,
            "customer"=>{
              "id"=>5241025160,
              "email"=>"chris@example.com",
              "accepts_marketing"=>false,
              "created_at"=>"2017-05-26T16:13:35+10:00",
              "updated_at"=>"2017-05-29T10:19:19+10:00",
              "first_name"=>"Chris",
              "last_name"=>"Cordial",
              "orders_count"=>4,
              "state"=>"disabled",
              "total_spent"=>"98.81",
              "last_order_id"=>4870678024,
              "note"=>"",
              "verified_email"=>true,
              "multipass_identifier"=>nil,
              "tax_exempt"=>false,
              "phone"=>"+61411245541",
              "tags"=>"",
              "last_order_name"=>"#1011",
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
            "entity"=>"orders",
            "org_uid"=>"cld-94oc",
            "webhook"=>{
              "id"=>4870678024,
              "email"=>"chris@example.com",
              "closed_at"=>nil,
              "created_at"=>"2017-05-29T10:19:19+10:00",
              "updated_at"=>"2017-05-29T10:19:19+10:00",
              "number"=>11,
              "note"=>nil,
              "token"=>"be1113c5213e51771dacc2d5dccecbac",
              "gateway"=>"manual",
              "test"=>false,
              "total_price"=>"18.41",
              "subtotal_price"=>"13.41",
              "total_weight"=>0,
              "total_tax"=>"1.22",
              "taxes_included"=>true,
              "currency"=>"AUD",
              "financial_status"=>"paid",
              "confirmed"=>true,
              "total_discounts"=>"1.49",
              "total_line_items_price"=>"14.90",
              "cart_token"=>nil,
              "buyer_accepts_marketing"=>false,
              "name"=>"#1011",
              "referring_site"=>nil,
              "landing_site"=>nil,
              "cancelled_at"=>nil,
              "cancel_reason"=>nil,
              "total_price_usd"=>"13.71",
              "checkout_token"=>nil,
              "reference"=>nil,
              "user_id"=>118786952,
              "location_id"=>nil,
              "source_identifier"=>nil,
              "source_url"=>nil,
              "processed_at"=>"2017-05-29T10:19:19+10:00",
              "device_id"=>nil,
              "phone"=>nil,
              "browser_ip"=>nil,
              "landing_site_ref"=>nil,
              "order_number"=>1011,
              "discount_codes"=>nil,
              "note_attributes"=>nil,
              "payment_gateway_names"=>[
                "manual"
              ],
              "processing_method"=>"manual",
              "checkout_id"=>nil,
              "source_name"=>"shopify_draft_order",
              "fulfillment_status"=>nil,
              "tax_lines"=>[
                {
                  "title"=>"GST",
                  "price"=>"1.22",
                  "rate"=>0.1
                }
              ],
              "tags"=>"",
              "contact_email"=>"chris@example.com",
              "order_status_url"=>nil,
              "line_items"=>[
                {
                  "id"=>9335992904,
                  "variant_id"=>36814965192,
                  "title"=>"Double Beef Burger",
                  "quantity"=>1,
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
                  "fulfillable_quantity"=>1,
                  "total_discount"=>"1.49",
                  "fulfillment_status"=>nil,
                  "tax_lines"=>[
                    {
                      "title"=>"GST",
                      "price"=>"1.22",
                      "rate"=>0.1
                    }
                  ]
                }
              ],
              "shipping_lines"=>[
                {
                  "id"=>4051086472,
                  "title"=>"Delivery",
                  "price"=>"5.00",
                  "code"=>"custom",
                  "source"=>"shopify",
                  "phone"=>nil,
                  "requested_fulfillment_service_id"=>nil,
                  "delivery_category"=>nil,
                  "carrier_identifier"=>nil,
                  "tax_lines"=>nil
                }
              ],
              "billing_address"=>{
                "first_name"=>"Chris",
                "address1"=>nil,
                "phone"=>nil,
                "city"=>nil,
                "zip"=>nil,
                "province"=>"Australian Capital Territory",
                "country"=>"Australia",
                "last_name"=>"Cordial",
                "address2"=>nil,
                "company"=>nil,
                "latitude"=>nil,
                "longitude"=>nil,
                "name"=>"Chris Cordial",
                "country_code"=>"AU",
                "province_code"=>"ACT"
              },
              "shipping_address"=>{
                "first_name"=>"Chris",
                "address1"=>nil,
                "phone"=>nil,
                "city"=>nil,
                "zip"=>nil,
                "province"=>"Australian Capital Territory",
                "country"=>"Australia",
                "last_name"=>"Cordial",
                "address2"=>nil,
                "company"=>nil,
                "latitude"=>nil,
                "longitude"=>nil,
                "name"=>"Chris Cordial",
                "country_code"=>"shipping_address.country",
                "province_code"=>"ACT"
              },
              "fulfillments"=>nil,
              "refunds"=>nil,
              "customer"=>{
                "id"=>5241025160,
                "email"=>"chris@example.com",
                "accepts_marketing"=>false,
                "created_at"=>"2017-05-26T16:13:35+10:00",
                "updated_at"=>"2017-05-29T10:19:19+10:00",
                "first_name"=>"Chris",
                "last_name"=>"Cordial",
                "orders_count"=>4,
                "state"=>"disabled",
                "total_spent"=>"98.81",
                "last_order_id"=>4870678024,
                "note"=>"",
                "verified_email"=>true,
                "multipass_identifier"=>nil,
                "tax_exempt"=>false,
                "phone"=>"+61411245541",
                "tags"=>"",
                "last_order_name"=>"#1011",
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
              }
            },
            "transactions"=>[
              {
                "id"=>5668555656,
                "amount"=>"18.41",
                "kind"=>"sale",
                "gateway"=>"manual",
                "status"=>"success",
                "message"=>"Marked the manual payment as received",
                "created_at"=>"2017-05-29T10:19:19+10:00",
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
                    "id"=>9335992904,
                    "variant_id"=>36814965192,
                    "title"=>"Double Beef Burger",
                    "quantity"=>1,
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
                    "fulfillable_quantity"=>1,
                    "total_discount"=>"1.49",
                    "fulfillment_status"=>nil,
                    "tax_lines"=>[
                      {
                        "title"=>"GST",
                        "price"=>"1.22",
                        "rate"=>0.1
                      }
                    ]
                  }
                ],
                "shipping_lines"=>[
                  {
                    "id"=>4051086472,
                    "title"=>"Delivery",
                    "price"=>"5.00",
                    "code"=>"custom",
                    "source"=>"shopify",
                    "phone"=>nil,
                    "requested_fulfillment_service_id"=>nil,
                    "delivery_category"=>nil,
                    "carrier_identifier"=>nil,
                    "tax_lines"=>nil
                  }
                ],
                "order_id"=>4870678024,
                "customer"=>{
                  "id"=>5241025160,
                  "email"=>"chris@example.com",
                  "accepts_marketing"=>false,
                  "created_at"=>"2017-05-26T16:13:35+10:00",
                  "updated_at"=>"2017-05-29T10:19:19+10:00",
                  "first_name"=>"Chris",
                  "last_name"=>"Cordial",
                  "orders_count"=>4,
                  "state"=>"disabled",
                  "total_spent"=>"98.81",
                  "last_order_id"=>4870678024,
                  "note"=>"",
                  "verified_email"=>true,
                  "multipass_identifier"=>nil,
                  "tax_exempt"=>false,
                  "phone"=>"+61411245541",
                  "tags"=>"",
                  "last_order_name"=>"#1011",
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
                "transaction_number"=>1011
              }
            ]
          }
        }

        let(:connec_hash) {
          {
            'opts' => {'sparse' => false},
            "person_id"=>[{"id"=>5241025160, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
            "transaction_date"=>"2017-05-29T10:19:19+10:00",
            "transaction_number"=>1011,
            "title"=>"#1011",
            "shipping_address"=>{
              "region"=>"Australian Capital Territory",
              "country"=>"shipping_address.country"
            },
            "apply_tax_after_discount" => false,
            "billing_address"=>{
              "region"=>"Australian Capital Territory",
              "country"=>"AU"
            },
            "lines"=>[
              {
                "id"=>[{"id"=>9335992904, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
                "unit_price"=>{
                  "total_amount"=>14.9,
                  "tax_rate"=>10.0,
                  "currency"=>"AUD"
                },
                "quantity"=>1,
                "description"=>"Double Beef Burger",
                "reduction_percent"=>10.0,
                "item_id"=>[{"id"=>36814965192, "provider"=>"this_app", "realm"=>organization.oauth_uid}
                ]
              },
              {
                "id"=>[{"id"=>4051086472, "provider"=>"this_app", "realm"=>organization.oauth_uid}],
                "unit_price"=>{
                  "total_amount"=>5.0,
                  "tax_rate"=>20.0,
                  "currency"=>"AUD"
                },
                "description"=>"Shipping: Delivery",
                "quantity"=>1
              }
            ],
            "status"=>"PAID",
            "type"=>"CUSTOMER",
            "balance"=>0.0,
            "deposit"=>18.41,
            "id"=>[{"id"=>"4870678024", "provider"=>"this_app", "realm"=>organization.oauth_uid}
            ]
          }
        }

        it 'maps into a connec invoice' do
          expect(subject.map_to('Invoice', order.with_indifferent_access)).to eql(connec_hash)
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
