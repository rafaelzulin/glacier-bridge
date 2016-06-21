require 'test_helper'

class GlacierControllerTest < ActionController::TestCase
  # setup do
    # session_store session[:session_id], key = :glacier_client, value = Array.new
    # session_store session[:session_id], key = :region_value, value = "us-west-2"
  # end

  test "should get list_vaults" do
    session_store request.session_options[:id], :glacier_facade, default_access_configuration

    get :list_vaults
    assert_response :success
  end

   private
   def default_access_configuration
     glacier_facade = GlacierFacade.new default_access_key_id, default_secret_access_key, default_region
     def glacier_facade.list_vaults
       output = Aws::Glacier::Types::DescribeVaultOutput.new
       output.creation_date = Time.parse "2016-06-17 20:01:59 UTC"
       output.last_inventory_date = Time.parse "2016-06-18 12:31:15 UTC"
       output.number_of_archives = 3
       output.size_in_bytes = 5000
       output.vault_arn = "arn:aws:glacier:us-west-2:280517293289:vaults/rafael"
       output.vault_name = "rafael"
       return [output]
     end
     return glacier_facade
   end

   def session_store session_id, key, value
     Session.instance.store session_id, key, value
   end

   def default_access_key_id
     "AKIAJMEB2YZM3K767JAA"
   end

   def default_secret_access_key
     "vmGKnGRlx71ISsdAtxq+G9SGsPMiQgzfvGBrmkUb"
   end

   def default_region
     "us-west-2"
   end
end
