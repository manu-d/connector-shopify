require 'spec_helper'

describe Entities::SubEntities::Payment do

  describe 'class methods' do
    subject { Entities::SubEntities::Payment }

    it { expect(subject.external?).to eql(false) }
    it { expect(subject.entity_name).to eql('Payment') }
    it { expect(subject.object_name_from_connec_entity_hash({'title' => 'Product'})).to eql('Product') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::SubEntities::Payment.new(organization, connec_client, external_client, opts) }

    describe 'mapping to shopify' do
      #TODO
    end
  end
end
