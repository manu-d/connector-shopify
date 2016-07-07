require 'spec_helper'

describe Entities::SubEntities::Payment do

  describe 'class methods' do
    subject { Entities::SubEntities::Payment }

    it { expect(subject.external?).to eql(false) }
    it { expect(subject.entity_name).to eql('Payment') }
    it { expect(subject.object_name_from_connec_entity_hash({'title' => 'Product'})).to eql('Product') }
  end
end
