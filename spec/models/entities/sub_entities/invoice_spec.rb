require 'spec_helper'

describe Entities::SubEntities::Invoice do
  describe 'class methods' do
    subject { Entities::SubEntities::Invoice }
    it { expect(subject.external?).to eql(false) }
    it { expect(subject.entity_name).to eql('Invoice') }
  end
end
