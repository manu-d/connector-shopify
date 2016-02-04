require 'spec_helper'

describe Entities::ContactAndLead do
  describe 'instance methods' do
    subject { Entities::ContactAndLead.new }

    it { expect(subject.connec_entities_names).to eql(%w(person)) }
    it { expect(subject.external_entities_names).to eql(%w(contact lead)) }

    describe 'connec_model_to_external_model!' do
      let(:person1) { {'first_name' => 'Gary', 'is_lead' => false} }
      let(:person2) { {'first_name' => 'Alice', 'is_lead' => true} }

      let(:connec_hash) {
        {
          'person' => [person1, person2]
        }
      }
      let(:output_hash) {
        {
          'person' => {
            'contact' => [person1],
            'lead' => [person2]
          }
        }
      }

      it {
        subject.connec_model_to_external_model!(connec_hash)
        expect(connec_hash).to eql(output_hash)
      }
    end

    describe 'external_model_to_connec_model!' do
      let(:lead) { {'Name' => 'Arold'} }
      let(:contact) { {'Name' => 'Jane'} }

      let(:sf_hash) {
        {
          'contact' => [contact],
          'lead' => [lead]
        }
      }

      let(:output_hash) {
        {
          'contact' => {'person' => [contact]},
          'lead' => {'person' => [lead]}
        }
      }

      it {
        subject.external_model_to_connec_model!(sf_hash)
        expect(sf_hash).to eql(output_hash)
      }
    end
  end
end