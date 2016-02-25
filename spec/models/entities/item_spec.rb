require 'spec_helper'

describe Entities::Item do

  describe 'instance methods' do
    subject { Entities::Item.new }

    it { expect(subject.connec_entity_name).to eql('Item') }
    it { expect(subject.external_entity_name).to eql('Product') }
    it { expect(subject.mapper_class).to eql(ItemMapper) }

    describe 'connec_model_to_external_model!' do

      let(:connec_hash) {
        {
            name: 'product name',
            description: 'product description'
        }
      }
      let(:external_hash) {
        {
            title: 'product name',
            body_html: 'product description'
        }
      }

      it { expect(subject.map_to_connec(external_hash, nil)).to eql(connec_hash) }
      it { expect(subject.map_to_external(connec_hash, nil)).to eql(external_hash) }
    end

  end
end