require 'spec_helper'

describe Entities::SubEntities::LeadMapper do
  subject { Entities::SubEntities::LeadMapper }

  describe 'normalize' do
    let(:connec_hash) {
      {
        "id"=>"18b7c3c1-7cd8-0133-dd04-0620e3ce3a45",
        "code"=>"PE192",
        "status"=>"ACTIVE",
        "title"=>"Ms",
        "first_name"=>"Phyllis",
        "last_name"=>"Cotton",
        "job_title"=>"CFO",
        "is_customer"=>true,
        "is_supplier"=>false,
        "is_lead"=>true,
        "address_work"=>
        {
        "billing"=>{"region"=>"VA", "country"=>"United States"},
         "billing2"=>{},
         "shipping"=>{},
         "shipping2"=>{}
        },
        "address_home"=>
        {
        "billing"=>{}, "billing2"=>{}, "shipping"=>{}, "shipping2"=>{}
        },
        "email"=>{"address"=>"pcotton@abbottins.net"},
        "website"=>{},
        "phone_work"=>{"landline"=>"(703) 757-1000"},
        "phone_home"=>{},
        "lead_status"=>"Open - Not Contacted",
        "lead_source"=>"Web",
        "lead_status_changes"=>
        [
          {"status"=>"Open - Not Contacted", "created_at"=>"2015-12-04T17:12:18Z"}
        ],
        "referred_leads"=>[],
        "opportunities"=>[],
        "notes"=>[],
        "tasks"=>[],
        "created_at"=>"2015-12-04T17:12:18Z",
        "updated_at"=>"2015-12-04T17:12:18Z",
        "group_id"=>"cld-94m8",
        "channel_id"=>"org-fg5b",
        "resource_type"=>"people"
      }
    }

    let(:output_hash) {
      {
        :Salutation=>"Ms",
        :FirstName=>"Phyllis",
        :LastName=>"Cotton",
        :Title=>"CFO",
        :State=>"VA",
        :Country=>"United States",
        :Email=>"pcotton@abbottins.net",
        :Phone=>"(703) 757-1000",
        :LeadSource=>"Web",
        :Status=>"Open - Not Contacted"
      }
    }

    it { expect(subject.normalize(connec_hash)).to eql(output_hash) }
  end

  describe 'denormalize' do
    let(:sf_hash) {
      {
        "attributes"=>
          {
            "type"=>"Lead",
            "url"=>"/services/data/v32.0/sobjects/Lead/00Q28000003FcanEAC"
          },
          "Id"=>"00Q28000003FcanEAC",
          "IsDeleted"=>false,
          "MasterRecordId"=>nil,
          "LastName"=>"Glimpse",
          "FirstName"=>"Jeff",
          "Salutation"=>"Mr",
          "Name"=>"Jeff Glimpse",
          "Title"=>"SVP, Procurement",
          "Company"=>"Jackson Controls",
          "Street"=>nil,
          "City"=>nil,
          "State"=>nil,
          "PostalCode"=>nil,
          "Country"=>"Taiwan, Republic Of China",
          "Latitude"=>nil,
          "Longitude"=>nil,
          "Address"=>
          {
            "city"=>nil,
            "country"=>"Taiwan, Republic Of China",
            "countryCode"=>nil,
            "geocodeAccuracy"=>nil,
            "latitude"=>nil,
            "longitude"=>nil,
            "postalCode"=>nil,
            "state"=>nil,
            "stateCode"=>nil,
            "street"=>nil
          },
          "Phone"=>"886-2-25474189",
          "MobilePhone"=>nil,
          "Fax"=>nil,
          "Email"=>"jeffg@jackson.com",
          "Website"=>nil,
          "PhotoUrl"=>"/services/images/photo/00Q28000003FcanEAC",
          "Description"=>nil,
          "LeadSource"=>"Phone Inquiry",
          "Status"=>"Open - Not Contacted",
          "Industry"=>nil,
          "Rating"=>nil,
          "AnnualRevenue"=>nil,
          "NumberOfEmployees"=>nil,
          "OwnerId"=>"00528000001eP9OAAU",
          "IsConverted"=>false,
          "ConvertedDate"=>nil,
          "ConvertedAccountId"=>nil,
          "ConvertedContactId"=>nil,
          "ConvertedOpportunityId"=>nil,
          "IsUnreadByOwner"=>false,
          "CreatedDate"=>"2015-11-29T15:24:02.000+0000",
          "CreatedById"=>"00528000001eP9OAAU",
          "LastModifiedDate"=>"2015-12-04T17:43:01.000+0000",
          "LastModifiedById"=>"00528000001eP9OAAU",
          "SystemModstamp"=>"2015-12-04T17:43:01.000+0000",
          "LastActivityDate"=>nil,
          "LastViewedDate"=>"2015-12-17T10:20:44.000+0000",
          "LastReferencedDate"=>"2015-12-17T10:20:44.000+0000",
          "Jigsaw"=>nil,
          "JigsawContactId"=>nil,
          "CleanStatus"=>"Pending",
          "CompanyDunsNumber"=>nil,
          "DandbCompanyId"=>nil,
          "EmailBouncedReason"=>nil,
          "EmailBouncedDate"=>nil,
          "SICCode__c"=>"2768",
          "ProductInterest__c"=>"GC5000 series",
          "Primary__c"=>"Yes",
          "CurrentGenerators__c"=>"All",
          "NumberofLocations__c"=>130.0
        }
    }

    let(:output_hash) {
      {
      :title=>"Mr",
        :first_name=>"Jeff",
        :last_name=>"Glimpse",
        :job_title=>"SVP, Procurement",
        :address_work=>
        {
          :billing=>{:country=>"Taiwan, Republic Of China"}
        },
        :email=>{:address=>"jeffg@jackson.com"},
        :phone_work=>{:landline=>"886-2-25474189"},
        :lead_source=>"Phone Inquiry",
        :lead_status=>"Open - Not Contacted"
      }
    }

    it { expect(subject.denormalize(sf_hash)).to eql(output_hash) }
  end
end