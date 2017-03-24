require 'spec_helper'

describe ShopifyClient do
  let(:oauth_token) { 'oauth_token' }
  let(:oauth_uid) { 'oauth_uid' }

  let(:client) { ShopifyClient.new  oauth_uid, oauth_token}

  it 'oauth_uid getter is working' do
    expect(client.oauth_uid).to be(oauth_uid)
  end
  it 'oauth_token getter is working' do
    expect(client.oauth_token).to be(oauth_token)
  end

  describe '#find' do

    it 'fetches the entities' do
      
    end
  end
end
