require 'spec_helper'

describe Entities::Payment do

  describe 'class methods' do
    subject { Entities::Payment }

    it { expect(subject.connec_entities_names).to eql(%w(Payment Opportunity)) }
    it { expect(subject.external_entities_names).to eql(%w(Transaction)) }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::Payment.new(organization, connec_client, external_client, opts) }

    describe 'connec_model_to_external_model' do
      it { expect(subject.connec_model_to_external_model({'Payment' => [{}]})).to eql({'Payment' => {'Transaction' => [{}]}}) }
    end

    describe 'external_model_to_connec_model' do
      it { expect(subject.external_model_to_connec_model({'Transaction' => [{}]})).to eql({'Transaction' => {'Payment' => [{}], 'Opportunity' => [{}]}}) }
    end
  end
end
