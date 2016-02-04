require 'spec_helper'

describe Entities::SubEntities::ContactMapper do
  subject { Entities::SubEntities::ContactMapper }

  describe 'normalize' do
    let(:connec_hash) {
      {
        "id"=>"eb8004d1-78db-0133-67ba-0620e3ce3a45",
        "code"=>"PE3",
        "status"=>"ACTIVE",
        "title"=>"Mr.",
        "first_name"=>"Avi",
        "last_name"=>"Green",
        "job_title"=>"CFO",
        "birth_date"=>"1929-06-07T00:00:00Z",
        "organization_id"=>"e0b36e71-78db-0133-1f34-025dd6a1bb31",
        "is_customer"=>true,
        "is_supplier"=>false,
        "is_lead"=>false,
        "address_work"=>
        {
        "billing"=>
          {"line1"=>"1302 Avenue of the Americas \nNew York, NY 10019\nUSA"},
         "billing2"=>{},
         "shipping"=>{},
         "shipping2"=>{}
        },
        "address_home"=>
        {
        "billing"=>{}, "billing2"=>{}, "shipping"=>{}, "shipping2"=>{}
        },
        "email"=>{"address"=>"agreen@uog.com"},
        "website"=>{},
        "phone_work"=>
        {
        "landline"=>"(212) 842-5500",
         "mobile"=>"(212) 842-2383",
         "fax"=>"(212) 842-5501"
         },
        "phone_home"=>{},
        "lead_status_changes"=>[],
        "referred_leads"=>[],
        "opportunities"=>[],
        "notes"=>[],
        "tasks"=>[],
        "created_at"=>"2015-11-29T15:29:35Z",
        "updated_at"=>"2015-11-29T16:00:18Z",
        "group_id"=>"cld-94m8",
        "channel_id"=>"org-fg5b",
        "resource_type"=>"people"
      }
    }

    let(:output_hash) {
      {
        :AccountId=>"e0b36e71-78db-0133-1f34-025dd6a1bb31",
        :Salutation=>"Mr.",
        :FirstName=>"Avi",
        :LastName=>"Green",
        :Title=>"CFO",
        :Birthdate=>"1929-06-07T00:00:00Z",
        :MailingStreet=>"1302 Avenue of the Americas \nNew York, NY 10019\nUSA",
        :Email=>"agreen@uog.com",
        :Phone=>"(212) 842-5500",
        :MobilePhone=>"(212) 842-2383",
        :Fax=>"(212) 842-5501"
      }
    }

    it { expect(subject.normalize(connec_hash)).to eql(output_hash) }
  end

  describe 'denormalize' do
    let(:sf_hash) {
      {
        "attributes"=>
        {
          "type"=>"Contact",
          "url"=>"/services/data/v32.0/sobjects/Contact/0032800000ABs2zAAD"
        },
        "Id"=>"0032800000ABs2zAAD",
        "IsDeleted"=>false,
        "MasterRecordId"=>nil,
        "AccountId"=>"0012800000CaxiJAAR",
        "LastName"=>"Gonzalez",
        "FirstName"=>"Rose",
        "Salutation"=>"Ms.",
        "Name"=>"Rose Gonzalez",
        "OtherStreet"=>nil,
        "OtherCity"=>nil,
        "OtherState"=>nil,
        "OtherPostalCode"=>nil,
        "OtherCountry"=>nil,
        "OtherLatitude"=>nil,
        "OtherLongitude"=>nil,
        "OtherAddress"=>nil,
        "MailingStreet"=>"313 Constitution Place\nAustin, TX 78767\nUSA",
        "MailingCity"=>nil,
        "MailingState"=>nil,
        "MailingPostalCode"=>nil,
        "MailingCountry"=>nil,
        "MailingLatitude"=>nil,
        "MailingLongitude"=>nil,
        "MailingAddress"=>
        {
          "city"=>nil,
          "country"=>nil,
          "countryCode"=>nil,
          "geocodeAccuracy"=>nil,
          "latitude"=>nil,
          "longitude"=>nil,
          "postalCode"=>nil,
          "state"=>nil,
          "stateCode"=>nil,
          "street"=>"313 Constitution Place\nAustin, TX 78767\nUSA"
        },
        "Phone"=>"(512) 757-6000",
        "Fax"=>"(512) 757-9000",
        "MobilePhone"=>"(512) 757-9340",
        "HomePhone"=>nil,
        "OtherPhone"=>nil,
        "AssistantPhone"=>nil,
        "ReportsToId"=>nil,
        "Email"=>"rose@edge.com",
        "Title"=>"SVP, Procurement",
        "Department"=>nil,
        "AssistantName"=>nil,
        "LeadSource"=>nil,
        "Birthdate"=>"1963-11-08",
        "Description"=>nil,
        "OwnerId"=>"00528000001eP9OAAU",
        "CreatedDate"=>"2015-12-04T18:08:20.000+0000",
        "CreatedById"=>"00528000001eP9OAAU",
        "LastModifiedDate"=>"2015-12-04T18:08:20.000+0000",
        "LastModifiedById"=>"00528000001eP9OAAU",
        "SystemModstamp"=>"2015-12-04T18:08:20.000+0000",
        "LastActivityDate"=>nil,
        "LastCURequestDate"=>nil,
        "LastCUUpdateDate"=>nil,
        "LastViewedDate"=>"2015-12-17T10:08:56.000+0000",
        "LastReferencedDate"=>"2015-12-17T10:08:56.000+0000",
        "EmailBouncedReason"=>nil,
        "EmailBouncedDate"=>nil,
        "IsEmailBounced"=>false,
        "PhotoUrl"=>"/services/images/photo/0032800000ABs2zAAD",
        "Jigsaw"=>nil,
        "JigsawContactId"=>nil,
        "CleanStatus"=>"Pending",
        "Level__c"=>nil,
        "Languages__c"=>nil
      }
    }

    let(:output_hash) {
      {
        :opts=>{"create_default_organization"=>true},
        :organization_id=>"0012800000CaxiJAAR",
        :title=>"Ms.",
        :first_name=>"Rose",
        :last_name=>"Gonzalez",
        :job_title=>"SVP, Procurement",
        :birth_date=>Date.parse('1963-11-08').to_time.iso8601,
        :address_work=>
        {
          :billing=>{:line1=>"313 Constitution Place\nAustin, TX 78767\nUSA"}
        },
        :email=>{:address=>"rose@edge.com"},
        :phone_work=>
        {
          :landline=>"(512) 757-6000",
          :mobile=>"(512) 757-9340",
          :fax=>"(512) 757-9000"
        }
      }
    }

    it { expect(subject.denormalize(sf_hash)).to eql(output_hash) }
  end
end