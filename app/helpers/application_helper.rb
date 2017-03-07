module ApplicationHelper

  def format_errors(object)
    "#{object.errors.messages.values.join(' ')}"
  end

  def connec_currency
	@connec_currency ||= company_currency
  end

  def shopify_currency
	@shopify_currency ||= store_currency
  end

  def company_currency
	connec_client = Maestrano::Connector::Rails::ConnecHelper.get_client(current_organization)
    connec_response_hash = JSON.parse(connec_client.get('company').body)
    connec_response_hash.dig('company', 'currency')
  rescue => e
    Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error while getting connec currency: #{e}")
    nil
  end

  def store_currency
	shopify_client = Maestrano::Connector::Rails::External.get_client(current_organization)
    shopify_response_hash = shopify_client.find('Shop').first
    shopify_response_hash['currency']
  rescue => e
    Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error while getting shopify currency: #{e}")
    nil
  end

  def is_same_currency
	connec_currency.blank? || shopify_currency.blank? || connec_currency == shopify_currency
  end

  def alert_msg
    "Warning: Your shop has a different currency than your company (#{shopify_currency} vs #{connec_currency}).\\n" +
    "As a result, the price of your products in #{connec_currency} will be set to 0 in Shopify, and you will have to modify them manually.\\n" +
    "Moreover, any price update in Shopify will not be reflected in other apps."
  end
end
