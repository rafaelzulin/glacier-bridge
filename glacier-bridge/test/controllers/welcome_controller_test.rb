require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  setup do
    request.env["HTTP_REFERER"] = "localhost"
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_template :index
    assert_template layout: "layouts/application"
  end

  test "should post acesss_register" do
    post :access_register, access_key_id: access_key_id_default, secret_access_key: secret_access_key_default, region: region_default
    assert_redirected_to glacier_list_vaults_path
  end
end
