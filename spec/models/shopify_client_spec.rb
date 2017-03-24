require 'spec_helper'
require 'shopify_api'

describe ShopifyClient do
  let(:oauth_token) { 'oauth_token' }
  let(:oauth_uid) { 'oauth_uid' }

  subject { ShopifyClient.new  oauth_uid, oauth_token}

  it 'oauth_uid getter is working' do
    expect(subject.oauth_uid).to be(oauth_uid)
  end
  it 'oauth_token getter is working' do
    expect(subject.oauth_token).to be(oauth_token)
  end

  describe '#find' do

    context 'when the entity name is Shop' do

      before { allow(JSON).to receive(:parse).and_return({'test'=> 1})}

      it 'fetches the first company' do
        expect(ShopifyAPI::Shop).to receive(:current)
        subject.find('Shop')
      end

      it 'returns an array with the parsed response' do
        allow(ShopifyAPI::Shop).to receive(:current)
        expect(subject.find('Shop')).to eq [{'test'=> 1}]
      end
    end

    context 'with all other enities' do

      let(:entity) { 'An Entity Class'}

      it 'calls find_all' do

        expect(subject).to receive(:find_all).and_return([])
        expect(subject).to receive(:get_shopify_entity_constant).and_return(entity)
        subject.find('Entity')
      end
    end
  end

  describe '#currency' do
    before { allow(JSON).to receive(:parse).and_return({'test'=> 1, 'currency'=> 'GBP'})}

    it 'retrieves the currency from the Shop endpoint' do

      allow(ShopifyAPI::Shop).to receive(:current)
      expect(subject.currency).to eq('GBP')
    end
  end

  describe '#create' do

    it 'calls update with the params passed' do
      expect(subject).to receive(:update).with(1, 2).and_return([])
      subject.create(1, 2)
    end
  end

  describe '#update' do

    let(:entity) { 'An Entity Class'}
    let(:response) { {'success'=> true}}
    let(:errors) { 'An object'}

    it 'Uses the API gem to POST the entity calling #create on the class' do
      expect(subject).to receive(:get_shopify_entity_constant).and_return(entity)
      expect(entity).to receive(:create).with(2).and_return(response)
      allow(response).to receive(:errors).and_return(errors)
      allow(errors).to receive(:messages).and_return([])
      expect(subject.update(1, 2)).to eq ({'success'=> true})
    end
  end
end
