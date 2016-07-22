FactoryGirl.define do

  factory :organization, class: Maestrano::Connector::Rails::Organization do
    sequence(:name, 'a') { |n| 'Organisation ' + n }
    tenant 'default'
    sequence(:oauth_uid, 'a') { |n| 'oauth_uid-' + n }
    sequence(:oauth_provider, 'a') { |n| 'oauth_provider-' + n }
  end

  factory :idmap, class: Maestrano::Connector::Rails::IdMap do
    connec_id '6798-ada6-te43'
    connec_entity 'person'
    external_id '4567ada66'
    external_entity 'contact'
    last_push_to_external 2.day.ago
    last_push_to_connec 1.day.ago
    association :organization
  end

  factory :synchronization, class: Maestrano::Connector::Rails::Synchronization do
    association :organization
    status 'SUCCESS'
    partial false
  end
end
