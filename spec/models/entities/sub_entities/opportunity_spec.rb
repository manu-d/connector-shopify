require 'spec_helper'

describe Entities::SubEntities::Opportunity do
  describe 'class methods' do
    subject { Entities::SubEntities::Opportunity }
    it { expect(subject.external?).to eql(false) }
    it { expect(subject.entity_name).to eql('Opportunity') }
  end
end
