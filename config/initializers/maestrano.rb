Maestrano.auto_configure unless Rails.env.test?
Maestrano.configure { |config| config.environment = 'local' } if Rails.env.test?
