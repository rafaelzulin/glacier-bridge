require 'test_helper'

class SimpleAccessFlowTest < ActionDispatch::IntegrationTest

  test "can see the first page" do
    get root_path
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
      assert_select "input[type=submit][name=commit][value=Start]"
    end
  end
end
