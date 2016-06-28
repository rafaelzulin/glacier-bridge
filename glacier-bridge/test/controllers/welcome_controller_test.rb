require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  setup do
    request.env["HTTP_REFERER"] = "localhost"
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_template :index
    assert_template layout: layout_default
  end

  test "should post acesss_register" do
    post :access_register, access_key_id: access_key_id_default, secret_access_key: secret_access_key_default, region: region_default
    assert_redirected_to glacier_list_vaults_path
    assert_not_nil Session.instance.recover(request.session_options[:id], :glacier_facade)
  end

  test "post access_register without parameters" do
    post :access_register
    assert_response :redirect
    assert_redirected_to welcome_index_path
    assert_equal "param is missing or the value is empty: Required parameters are missing: access_key_id secret_access_key region", flash[:error]
  end

  test "post access_register without access key id" do
    post :access_register, access_key_id: nil, secret_access_key: secret_access_key_default, region: region_default
    assert_response :redirect
    assert_redirected_to welcome_index_path
    assert_equal "param is missing or the value is empty: Required parameters are missing: access_key_id", flash[:error]
  end
end
