require 'spec_helper'

describe Entities::Item do

  describe 'class methods' do
    subject { Entities::Item }

    describe 'get_pricebook_id' do
      let(:client) { Restforce.new }
      let(:pricebook1) { {'IsStandard' => false, 'Id' => '7766A'} }
      let(:pricebook2) { {'IsStandard' => true, 'Id' => '7766B'} }
      let(:pricebooks) { [pricebook1, pricebook2] }

      context 'with no standard pricebook' do
        before {
          allow(client).to receive(:query).and_return([pricebook1])
        }

        it { expect{ subject.get_pricebook_id(client) }.to raise_error('No standard pricebook found') }
      end

      context 'with a standard pricebook' do
        before {
          allow(client).to receive(:query).and_return(pricebooks)
        }

        it { expect(subject.get_pricebook_id(client)).to eql('7766B') }
      end
    end
  end

  describe 'instance methods' do
    subject { Entities::Item.new }

    it { expect(subject.connec_entities_names).to eql(%w(item)) }
    it { expect(subject.external_entities_names).to eql(%w(Product2 PricebookEntry)) }

    describe 'connec_model_to_external_model!' do
      let(:item1) { {'name' => 'Glass'} }
      let(:item2) { {'name' => 'TV'} }

      let(:connec_hash) {
        {
          'item' => [item1, item2]
        }
      }
      let(:output_hash) {
        {
          'item' => {
            'Product2' => [item1, item2],
            'PricebookEntry' => [item1, item2]
          }
        }
      }

      it {
        subject.connec_model_to_external_model!(connec_hash)
        expect(connec_hash).to eql(output_hash)
      }
    end

    describe 'external_model_to_connec_model!' do
      let(:product) { {'Name' => 'Laptop'} }
      let(:price) { {'Price' => 3000} }
      let(:sf_hash) {
        {
          'Product2' => [product],
          'PricebookEntry' => [price]
        }
      }

      let(:output_hash) {
        {
          'Product2' => {'item' => [product]},
          'PricebookEntry' => {'item' => [price]}
        }
      }

      it {
        subject.external_model_to_connec_model!(sf_hash)
        expect(sf_hash).to eql(output_hash)
      }
    end
  end
end