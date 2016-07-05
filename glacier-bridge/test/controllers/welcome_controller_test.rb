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
    assert_select "form[name=form_welcome][action='/welcome/access_register'][method=post]", count: 1
    assert_select "form select[name=region][required]", count: 1 do
      assert_select "option", count: 10
      assert_select "option[value=us-east-1]", count: 1
      assert_select "option[value=us-west-1]", count: 1
      assert_select "option[value=us-west-2]", count: 1
      assert_select "option[value=ap-south-1]", count: 1
      assert_select "option[value=ap-northeast-2]", count: 1
      assert_select "option[value=ap-southeast-2]", count: 1
      assert_select "option[value=ap-northeast-1]", count: 1
      assert_select "option[value=eu-central-1]", count: 1
      assert_select "option[value=eu-west-1]", count: 1
    end
    assert_select "form input", count: 4 do
      assert_select "input[type=text][name=access_key_id][placeholder='Access Key ID'][required]", count: 1
      assert_select "input[type=text][name=secret_access_key][placeholder='Secret Access Key'][required]", count: 1
      assert_select "input[type=submit][name=commit][value=Start]", count: 1
    end
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
