

Maestrano::Connector::Rails::Organization.all.each do |organization|
  next unless organization.oauth_uid
  shop_name = organization.oauth_uid
  p "#{organization.uid}  #{shop_name} #{organization.name}"
  token = organization.oauth_token
  ShopifyAPI::Session.temp(shop_name, token) do
    begin
      ShopifyAPI::Webhook.all.each do |webhook|
        p webhook.address
      end
    rescue Exception => e
      puts e.message
    end
  end
end

Maestrano::Connector::Rails::Organization.all.each do |organization|
  next unless organization.oauth_uid
  p organization.oauth_uid
end