Restforce.configure do |config|
  config.api_version = '32.0' #get_updated not available in default api version
  config.mashify = false #Return arrays of hashs instead of custom SF collection
end