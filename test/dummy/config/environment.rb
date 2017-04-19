# Load the rails application
require File.expand_path('../application', __FILE__)

Rails.application.configure do
  config.active_support.test_order = :random
  config.eager_load = false
end

# Initialize the rails application
Dummy::Application.initialize!
