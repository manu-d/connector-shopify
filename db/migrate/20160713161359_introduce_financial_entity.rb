class IntroduceFinancialEntity < ActiveRecord::Migration
  def change
    Maestrano::Connector::Rails::Organization.all.each do |o|
      se = o.synchronized_entities
      add_financial = se.delete(:payment)
      add_financial |= se.delete(:sales_order)
      add_financial |= se.delete(:invoice)
      if (add_financial)
        se[:financial] = true
      end
      o.update(synchronized_entities: se)
    end

    Maestrano::Connector::Rails::IdMap.all.each do |id_map|
      connec_entity = id_map.connec_entity
      if connec_entity == 'invoice'
        id_map.update(external_entity: 'shopify invoice')
      end
      if connec_entity == 'payment' || connec_entity == 'opportunity'
        id_map.update(external_entity: 'transaction')
      end
      if connec_entity == 'sales_order'
        id_map.update(connec_entity: 'sales order')
      end

    end
  end
end
