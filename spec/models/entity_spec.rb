require 'spec_helper'

describe Maestrano::Connector::Rails::Entity do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::Entity }

    describe 'self.entities_list' do
      it { expect(subject.entities_list).to be_a(Array) }
    end
  end

  describe 'instance methods' do
    subject { Maestrano::Connector::Rails::Entity.new }
    let(:organization) { create(:organization) }
    let(:client) { Restforce.new }
    let(:external_name) { 'external_name' }
    before {
      allow(subject).to receive(:external_entity_name).and_return(external_name)
      allow(subject).to receive(:external_attributes).and_return(%w(FirstName LastName))
    }

    describe 'get_external_entities' do
      context 'with full sync option' do
        it 'uses a full query' do
          expect(client).to receive(:query).with(/select Id, LastModifiedDate, FirstName, LastName from #{external_name}/i)
          subject.get_external_entities(client, nil, organization, {full_sync: true})
        end
      end

      context 'without option' do
        context 'without last sync' do
          it 'uses a full query' do
            expect(client).to receive(:query).with(/select Id, LastModifiedDate, FirstName, LastName from #{external_name}/i)
            subject.get_external_entities(client, nil, organization)
          end
        end

        context 'with a last sync' do
          let(:last_sync) { create(:synchronization, updated_at: 1.hour.ago) }

          it 'uses get updated' do
            Timecop.freeze(Date.today) do
              allow(client).to receive(:get_updated).and_return({'ids' => []})
              expect(client).to receive(:get_updated).with(external_name, last_sync.updated_at, Time.now)
              subject.get_external_entities(client, last_sync, organization)
            end
          end

          it 'calls find on received ids' do
            allow(client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            expect(client).to receive(:find).with(external_name, 3)
            expect(client).to receive(:find).with(external_name, 5)
            expect(client).to receive(:find).with(external_name, 6)
            subject.get_external_entities(client, last_sync, organization)
          end

          it 'returns the entities' do
            allow(client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            allow(client).to receive(:find).and_return({'FirstName' => 'John'})
            expect(subject.get_external_entities(client, last_sync, organization)).to eql([{'FirstName' => 'John'}, {'FirstName' => 'John'}, {'FirstName' => 'John'}])
          end
        end
      end
    end

    describe 'create_entity_to_external' do
      it 'calls create!' do
        expect(client).to receive(:create!).with(external_name, {})
        subject.create_entity_to_external(client, {}, external_name, organization)
      end
    end

    describe 'update_entity_to_external' do
      it 'calls update! with the id' do
        expect(client).to receive(:update!).with(external_name, {'Id' => '3456'})
        subject.update_entity_to_external(client, {}, '3456', external_name, organization)
      end
    end

    describe 'get_id_from_external_entity_hash' do
      it { expect(subject.get_id_from_external_entity_hash({'Id' => '1234'})).to eql('1234') }
    end

    describe 'get_last_update_date_from_external_entity_hash' do
      it {
        Timecop.freeze(Date.today) do
          expect(subject.get_last_update_date_from_external_entity_hash({'LastModifiedDate' => 1.hour.ago})).to eql(1.hour.ago)
        end
      }
    end

  end

end