ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def region_default
    "us-west-2"
  end

  def access_key_id_default
    "AKIAJMEB2YZM3K767JAA"
  end

  def secret_access_key_default
    "vmGKnGRlx71ISsdAtxq+G9SGsPMiQgzfvGBrmkUb"
  end

  def layout_default
    "layouts/application"
  end
end
