require 'spec_helper'

describe Entities::SubEntities::Product2 do
  subject { Entities::SubEntities::Product2.new }

  it { expect(subject.external?).to be(true) }
  it { expect(subject.entity_name).to eql('Product2') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from Product2 to lala") } }
    end

    describe 'for a valid entity name' do
      it 'calls denormalize' do
        expect(Entities::SubEntities::Product2Mapper).to receive(:denormalize).with({})
        subject.map_to('item', {}, nil)
      end
    end
  end
end