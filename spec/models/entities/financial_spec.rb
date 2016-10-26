require 'spec_helper'

describe Entities::Financial do

  describe 'class methods' do
    subject { Entities::Financial }

    it { expect(subject.connec_entities_names).to eql(%w(Invoice Payment)) }
    it { expect(subject.external_entities_names).to eql(%w(Order Transaction)) }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::Financial.new(organization, connec_client, external_client, opts) }


    describe 'external_model_to_connec_model' do
      context 'without transactions' do
        let(:expected) {
          {
              'Order' => {'Invoice' => []},
              'Transaction' => {'Payment' => []}
          }
        }

        it { expect(subject.external_model_to_connec_model({'Order' => [{}]})).to eql(expected) }
      end
      context 'transactions' do
        let(:transactions) { [{'id' => 1, 'kind' => 'sale', 'status' => 'success'}, {'id' => 2, 'kind' => 'refund', 'status' => 'success'}, {'id' => 3, 'kind' => 'authorization', 'status' => 'pending'}] }
        let(:orders) { [{'id' => 'id', 'transactions' => transactions}] }
        let(:expected) {
          {
              'Order' => {'Invoice' => [{'id' => 3, 'kind' => 'authorization', 'status' => 'pending'}]},
              'Transaction' => { 'Payment' => [{'id' => 1, 'kind' => 'sale', 'status' => 'success'}, {'id' => 2, 'kind' => 'refund', 'status' => 'success'}]}
          }
        }
        it { expect(subject.external_model_to_connec_model({'Order' => orders})).to eql(expected) }
      end
    end
  end
end
