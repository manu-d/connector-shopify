require 'spec_helper'

describe Entities::SubEntities::Transaction do

  describe 'class methods' do
    subject { Entities::SubEntities::Transaction }

    it { expect(subject.entity_name).to eql('Transaction') }
    it { expect(subject.external?).to eql(true) }
    it { expect(subject.object_name_from_external_entity_hash({'id' => 'ABC'})).to eql('ABC') }
    it { expect(subject.last_update_date_from_external_entity_hash({'created_at' => Time.new(1985, 9, 17).iso8601})).to eql(Time.new(1985, 9, 17)) }

  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::SubEntities::Transaction.new(organization, connec_client, external_client, opts) }

    describe 'mapping to connec!' do
      let(:transaction) {
        {
            'id' => '1',
            'order_id' => 'N11003',
            'created_at' => '2016-06-12 23:26:26',
            'currency' => 'AUD',
            'amount' => 155.00,
            'customer' => {
                'id' => 'USER-ID'
            }
        }
      }

      describe 'payment' do
        let(:connec_payment) {
          {
              'id' => [{'id' => '1', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
              'payment_lines' => [
                  {
                      'id' => [{'id' => 'shopify-payment', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                      'amount' => 155.0,
                      'linked_transactions' => [
                          {
                              'id' => [{'id' => 'N11003', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                              'class' => 'Invoice'
                          },
                          {
                              'id' => [{'id' => 'N11003', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
                              'class' => 'SalesOrder'
                          }
                      ]
                  }
              ],
              'amount' => {'currency' => 'AUD', 'total_amount' => 155.0},
              'title' => 'N11003',
              'person_id' => [{'id' => 'USER-ID', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
              'transaction_date' => '2016-06-12 23:26:26',
              'type' => 'CUSTOMER',
              'status' => 'ACTIVE'
          }
        }


        context 'connec version is >= 1.1.12' do
          before do
            expect(Maestrano::Connector::Rails::ConnecHelper).to receive(:connec_version).with(organization).and_return('1.1.12')
          end
          it { expect(subject.map_to('Payment', transaction)).to eql(connec_payment) }
        end

        context 'connec version is < 1.1.12' do
          before do
            expect(Maestrano::Connector::Rails::ConnecHelper).to receive(:connec_version).with(organization).and_return('1.1.11')
          end

          it {
            connec_payment['payment_lines'].each{|line| line.delete('linked_transactions')}
            expect(subject.map_to('Payment', transaction)).to eql(connec_payment)
          }

        end
      end

      describe 'opportunity' do
        let(:connec_opportunity) {
          {
              'id' => [{'id' => '1', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}],
              'amount' => {'total_amount' => 155.0, 'currency' => 'AUD'},
              'name' => 'N11003',
              'probability' => 100,
              'sales_stage' => 'Closed Won',
              'sales_stage' => 'Closed Won',
              'lead_id' => [{'id' => 'USER-ID', 'provider' => organization.oauth_provider, 'realm' => organization.oauth_uid}]
          }
        }

        it { expect(subject.map_to('Opportunity', transaction)).to eql(connec_opportunity) }
      end
    end
  end
end

