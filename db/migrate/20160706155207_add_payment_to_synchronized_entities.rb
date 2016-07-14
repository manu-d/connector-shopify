class AddPaymentToSynchronizedEntities < ActiveRecord::Migration
  def change
    Maestrano::Connector::Rails::Organization.all.each do |o|
      se = o.synchronized_entities
      se = {payment: true}.merge(se)
      o.update(synchronized_entities: se)
      Maestrano::Connector::Rails::SynchronizationJob.perform_later(o, {forced: true, full_sync: true, only_entities: %w(payment)})
    end
  end
end
