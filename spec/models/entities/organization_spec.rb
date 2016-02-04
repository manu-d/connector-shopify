require 'spec_helper'

describe Entities::Organization do
  subject { Entities::Organization.new }

  it { expect(subject.connec_entity_name).to eql('Organization') }
  it { expect(subject.external_entity_name).to eql('Account') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'SalesForce to connec!' do
    let(:sf) {
      {
        "attributes"=>
        {
          "type"=>"Account",
          "url"=>"/services/data/v32.0/sobjects/Account/0012800000CaxiOAAR"
        },
        "Id"=>"0012800000CaxiOAAR",
        "IsDeleted"=>false,
        "MasterRecordId"=>nil,
        "Name"=>"Burlington Textiles Corp of America",
        "Type"=>nil,
        "ParentId"=>nil,
        "BillingStreet"=>"525 S. Lexington Ave",
        "BillingCity"=>"Burlington",
        "BillingState"=>"NC",
        "BillingPostalCode"=>"27215",
        "BillingCountry"=>"United States",
        "BillingLatitude"=>nil,
        "BillingLongitude"=>nil,
        "BillingAddress"=>
        {
          "city"=>"Burlington",
          "country"=>"United States",
          "countryCode"=>nil,
          "geocodeAccuracy"=>nil,
          "latitude"=>nil,
          "longitude"=>nil,
          "postalCode"=>"27215",
          "state"=>"NC",
          "stateCode"=>nil,
          "street"=>"525 S. Lexington Ave"
        },
        "ShippingStreet"=>nil,
        "ShippingCity"=>nil,
        "ShippingState"=>nil,
        "ShippingPostalCode"=>nil,
        "ShippingCountry"=>nil,
        "ShippingLatitude"=>nil,
        "ShippingLongitude"=>nil,
        "ShippingAddress"=>nil,
        "Phone"=>"(336) 222-7000",
        "Fax"=>"(336) 222-8000",
        "AccountNumber"=>nil,
        "Website"=>"www.burlington.com",
        "PhotoUrl"=>"/services/images/photo/0012800000CaxiOAAR",
        "Sic"=>nil,
        "Industry"=>"Apparel",
        "AnnualRevenue"=>350000000.0,
        "NumberOfEmployees"=>9000,
        "Ownership"=>nil,
        "TickerSymbol"=>nil,
        "Description"=>nil,
        "Rating"=>nil,
        "Site"=>nil,
        "OwnerId"=>"00528000001eP9OAAU",
        "CreatedDate"=>"2015-12-04T18:06:06.000+0000",
        "CreatedById"=>"00528000001eP9OAAU",
        "LastModifiedDate"=>"2015-12-04T18:06:06.000+0000",
        "LastModifiedById"=>"00528000001eP9OAAU",
        "SystemModstamp"=>"2015-12-04T18:06:06.000+0000",
        "LastActivityDate"=>nil,
        "LastViewedDate"=>"2015-12-04T18:06:06.000+0000",
        "LastReferencedDate"=>"2015-12-04T18:06:06.000+0000",
        "Jigsaw"=>nil,
        "JigsawCompanyId"=>nil,
        "CleanStatus"=>"Pending",
        "AccountSource"=>nil,
        "DunsNumber"=>nil,
        "Tradestyle"=>nil,
        "NaicsCode"=>nil,
        "NaicsDesc"=>nil,
        "YearStarted"=>nil,
        "SicDesc"=>nil,
        "DandbCompanyId"=>nil,
        "CustomerPriority__c"=>nil,
        "SLA__c"=>nil,
        "Active__c"=>nil,
        "NumberofLocations__c"=>nil,
        "UpsellOpportunity__c"=>nil,
        "SLASerialNumber__c"=>nil,
        "SLAExpirationDate__c"=>nil
      }
    }

    let (:mapped_sf) {
      {
        :name=>"Burlington Textiles Corp of America",
        :industry=>"Apparel",
        :annual_revenue=>350000000.0,
        :number_of_employees=>9000,
        :address=>
        {
          :billing=>
            {
              :line1=>"525 S. Lexington Ave",
              :city=>"Burlington",
              :region=>"NC",
              :postal_code=>"27215",
              :country=>"United States"
            }
        },
        :website=>{
          :url=>"www.burlington.com"
        },
        :phone=>{
          :landline=>"(336) 222-7000",
          :fax=>"(336) 222-8000"
        }
      }
    }

    it { expect(subject.map_to_connec(sf, nil)).to eql(mapped_sf) }
  end

  describe 'connec to salesforce' do
    let(:connec) {
      {
        "id"=>"cd946971-78db-0133-6798-0620e3ce3a45",
        "code"=>"OR3",
        "name"=>"GenePoint",
        "status"=>"ACTIVE",
        "industry"=>"Biotechnology",
        "annual_revenue"=>30000000.0,
        "number_of_employees"=>265,
        "referred_leads"=>[],
        "is_customer"=>true,
        "is_supplier"=>false,
        "is_lead"=>false,
        "address"=>
        {
          "billing"=>
          {
            "line1"=>"345 Shoreline Park\nMountain View, CA 94043\nUSA",
             "city"=>"Mountain View",
             "region"=>"CA"
          },
          "billing2"=>{},
          "shipping"=>
          {
            "line1"=>"345 Shoreline Park\nMountain View, CA 94043\nUSA"
          },
          "shipping2"=>{}
        },
        "email"=>{},
        "website"=>
        {
          "url"=>"www.genepoint.com"
        },
        "phone"=>{
          "landline"=>"(650) 867-3450", "fax"=>"(650) 867-9895"
        },
        "contact_channel"=>{},
        "created_at"=>"2015-11-29T15:28:45Z",
        "updated_at"=>"2015-11-29T15:28:45Z",
        "group_id"=>"cld-94m8",
        "channel_id"=>"org-fg5b",
        "resource_type"=>"organizations"
      }
    }

    let(:mapped_connec) {
      {
        :Name=>"GenePoint",
        :Industry=>"Biotechnology",
        :AnnualRevenue=>30000000.0,
        :NumberOfEmployees=>265,
        :BillingStreet=>"345 Shoreline Park\nMountain View, CA 94043\nUSA",
        :BillingCity=>"Mountain View",
        :BillingState=>"CA",
        :ShippingStreet=>"345 Shoreline Park\nMountain View, CA 94043\nUSA",
        :Website=>"www.genepoint.com",
        :Phone=>"(650) 867-3450",
        :Fax=>"(650) 867-9895"
      }
    }

    it { expect(subject.map_to_external(connec, nil)).to eql(mapped_connec) }
  end
end