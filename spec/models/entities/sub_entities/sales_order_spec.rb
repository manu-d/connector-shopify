require 'spec_helper'

describe Entities::SubEntities::SalesOrder do
  describe 'class methods' do
    subject { Entities::SubEntities::SalesOrder }

    it { expect(subject.entity_name).to eql('Sales Order') }
    it { expect(subject.object_name_from_external_entity_hash({'name' => 'the name'})).to eql('the name') }
  end
end
