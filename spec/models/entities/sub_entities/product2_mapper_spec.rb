require 'spec_helper'

describe Entities::SubEntities::Product2Mapper do
  subject { Entities::SubEntities::Product2Mapper }

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
      {:ProductCode=>"GC1040", :Name=>"GenWatt Diesel 200kW"}
    }

    it { expect(subject.normalize(connec_hash)).to eql(output_hash) }
  end

  describe 'denormalize' do
    let(:sf_hash) {
      {
        "attributes"=>
        {
          "type"=>"Product2",
          "url"=>"/services/data/v32.0/sobjects/Product2/01t28000000yjJ5AAI"
        },
        "Id"=>"01t28000000yjJ5AAI",
        "Name"=>"SLA: Platinum",
        "ProductCode"=>"SL9080",
        "Description"=>nil,
        "IsActive"=>false,
        "CreatedDate"=>"2015-12-05T13:09:45.000+0000",
        "CreatedById"=>"00528000001eP9OAAU",
        "LastModifiedDate"=>"2015-12-05T13:09:45.000+0000",
        "LastModifiedById"=>"00528000001eP9OAAU",
        "SystemModstamp"=>"2015-12-05T13:09:45.000+0000",
        "Family"=>nil,
        "IsDeleted"=>false,
        "LastViewedDate"=>"2015-12-05T13:18:09.000+0000",
        "LastReferencedDate"=>"2015-12-05T13:18:09.000+0000"
       }
    }

    let(:output_hash) {
      {:code=>"SL9080", :name=>"SLA: Platinum"}
    }

    it { expect(subject.denormalize(sf_hash)).to eql(output_hash) }
  end
end