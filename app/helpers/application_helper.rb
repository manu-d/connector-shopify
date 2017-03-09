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
    return ''
  end

  def store_currency
	  shopify_client = Maestrano::Connector::Rails::External.get_client(current_organization)
    shopify_response_hash = shopify_client.find('Shop').first
    shopify_response_hash['currency']
  rescue => e
    Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error while getting shopify currency: #{e} #{e.backtrace.join("\n")}")
    return ''
  end

  def is_same_currency
	  connec_currency.blank? || shopify_currency.blank? || connec_currency == shopify_currency
  end

  def alert_msg
    haml_tag :p do
      haml_concat "Your shop has a different currency than your company (#{shopify_currency} vs #{connec_currency})."
      haml_tag :br
      haml_concat "As a result, "
      haml_concat "<b>the price of your products in #{connec_currency} will be set to 0 in Shopify</b>, and you will have to modify them manually."
      haml_tag :br
      haml_concat "Moreover, "
      haml_concat "<b>any price update in Shopify will not be reflected in other apps.</b>"
    end
  end
end
