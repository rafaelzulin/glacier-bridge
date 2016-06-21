require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  setup do
    request.env["HTTP_REFERER"] = "localhost"
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should post acesss_register" do
    post :access_register, access_key_id: "teste", secret_access_key: "senha", region: "us-west-2"
    assert_redirected_to glacier_list_vaults_path
  end
end
