require 'spec_helper'

describe Entities::SubEntities::Contact do
  subject { Entities::SubEntities::Contact.new }

  it { expect(subject.external?).to be(true) }
  it { expect(subject.entity_name).to eql('contact') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from contact to lala") } }
    end

    describe 'for a valid entity name' do
      context 'when entity has no AccountId' do
        it 'calls denormalize' do
          expect(Entities::SubEntities::ContactMapper).to receive(:denormalize).with({})
          subject.map_to('person', {}, nil)
        end
      end

      context 'when entity has a AccountId field' do
        let(:organization) { create(:organization) }
        let(:sf_id) { '366AE3C' }
        let(:connec_id) { 'ab23-3er5-224fd' }

        context 'with no corresponding idmap' do
          it 'leaves the field blank' do
            expect(Entities::SubEntities::ContactMapper).to receive(:denormalize).with({'AccountId' => ''})
            subject.map_to('person', {'AccountId' => sf_id}, organization)
          end
        end

        context 'with a corresponding idmap' do
          let!(:idmap) { create(:idmap, organization: organization, external_entity: 'account', external_id: sf_id, connec_id: connec_id, connec_entity: 'organization') }

          it 'replace the field with the connec id' do
            expect(Entities::SubEntities::ContactMapper).to receive(:denormalize).with({'AccountId' => connec_id})
            subject.map_to('person', {'AccountId' => sf_id}, organization)
          end
        end
      end

    end
  end
end