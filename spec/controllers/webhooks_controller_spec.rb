require 'spec_helper'

describe WebhooksController, :type => :controller do

  let(:org_uid) { 'uid-123' }
  let(:organization) { create(:organization) }

  subject { post :receive, entity: 'products', type: 'create', org_uid: org_uid }

  describe 'receive' do

    before :each do
      allow(controller).to receive(:verify_request).and_return(true)
    end

    context 'when organization is not found' do

      before { allow(Maestrano::Connector::Rails::Organization).to receive(:find_by_uid).and_return(nil) }

      it 'logs a message and returns' do
        expect(Maestrano::Connector::Rails::ConnectorLogger).to receive(:log)

        expect(subject).to have_http_status(200)
      end
    end

    context 'when organization is found' do

      before { allow(Maestrano::Connector::Rails::Organization).to receive(:find_by_uid).and_return(organization) }

      context 'and the entity is products' do

        it 'gets the variants of the product' do
          expect(Entities::Item).to receive(:get_product_variants)

          subject
        end

      end

      context 'and the entity_name is orders' do

        subject { post :receive, entity: 'orders', type: 'create', org_uid: org_uid }

        before { allow(controller).to receive(:params).and_return({entity: 'orders'})}

        it 'retrieves the associated transactions' do
          expect(Maestrano::Connector::Rails::External).to receive(:get_client).with(organization).and_return('client')
          expect(Entities::SubEntities::Order).to receive(:get_order_transactions).with('client', {:entity=>"orders"})
          expect(Maestrano::Connector::Rails::PushToConnecWorker).to receive(:perform_async)

          subject
        end
      end
    end
  end
end
