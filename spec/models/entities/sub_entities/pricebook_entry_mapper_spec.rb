require 'spec_helper'

describe Entities::SubEntities::PricebookEntryMapper do
  subject { Entities::SubEntities::PricebookEntryMapper }

  describe 'normalize' do
    let(:connec_hash) {
      {
        "id"=>"4a38d6f1-7d78-0133-6440-0620e3ce3a45",
        "code"=>"GC1040",
        "name"=>"GenWatt Diesel 200kW",
        "status"=>"ACTIVE",
        "is_inventoried"=>false,
        "sale_price"=>{"net_amount"=>25000.0, "currency"=>"USD"},
        "purchase_price"=>{"currency"=>"USD"},
        "created_at"=>"2015-12-05T12:19:00Z",
        "updated_at"=>"2015-12-05T12:50:01Z",
        "group_id"=>"cld-94m8",
        "channel_id"=>"org-fg5b",
        "resource_type"=>"items"
      }
    }

    let(:output_hash) {
      {:UnitPrice=>25000.0}
    }

    it { expect(subject.normalize(connec_hash)).to eql(output_hash) }
  end

  describe 'denormalize' do
    let(:sf_hash) {
      {
        "attributes"=>
        {
          "type"=>"PricebookEntry",
          "url"=>"/services/data/v32.0/sobjects/PricebookEntry/01u28000001VcFyAAK"
        },
        "Id"=>"01u28000001VcFyAAK",
        "Name"=>"Installation: Industrial - High",
        "Pricebook2Id"=>"01s28000005Cuu4AAC",
        "Product2Id"=>"01t28000000sB8mAAE",
        "UnitPrice"=>85000.0,
        "IsActive"=>true,
        "UseStandardPrice"=>false,
        "CreatedDate"=>"2015-11-29T15:24:02.000+0000",
        "CreatedById"=>"00528000001eP9OAAU",
        "LastModifiedDate"=>"2015-11-29T15:24:02.000+0000",
        "LastModifiedById"=>"00528000001eP9OAAU",
        "SystemModstamp"=>"2015-11-29T15:24:02.000+0000",
        "ProductCode"=>"IN7080",
        "IsDeleted"=>false
      }
    }

    let(:output_hash) {
      {
        :sale_price=>{:net_amount=>85000.0},
        :Product2Id=>"01t28000000sB8mAAE"
      }
    }

    it { expect(subject.denormalize(sf_hash)).to eql(output_hash) }
  end
end