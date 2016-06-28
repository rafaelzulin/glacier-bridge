require 'test_helper'

class GlacierControllerTest < ActionController::TestCase
  setup do
    request.env["HTTP_REFERER"] = "localhost"
  end

  test "should get list_vaults happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_vaults
      Array.new.push Bridge::Types::Glacier::DescribeVaultOutput.new(vault_name: "vault_test",
        vault_arn: "arn:aws:glacier:us-west-2:280517293289:vaults/vault_test",
        size_in_bytes: 1024,
        number_of_archives: 2,
        creation_date: Time.new(2016, 06, 15, 02, 00, 00, "-03:00"),
        last_inventory_date: Time.new(2016, 06, 20, 17, 15, 00, "-03:00")
      )
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_vaults
    assert_response :success
    assert_template :list_vaults
    assert_template layout: layout_default
    assert_equal 1, assigns(:vaults_list).size
    assert_select "h1", "List of the vaults"
    assert_select "table thead tr", 1
    assert_select "table tbody tr", 1
  end

  test "should get list_vaults without vaults" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_vaults
      Array.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_vaults
    assert_response :success
    assert_template :list_vaults
    assert_template layout: layout_default
    assert_equal 0, assigns(:vaults_list).size
    assert_select "h1", "List of the vaults"
    assert_select "table thead tr", 1
    assert_select "table tbody tr", 0
  end

  test "should get list_vaults with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_vaults
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_vaults
    assert_response :redirect
    assert_redirected_to "/500.html"
  end

  test "should get list_jobs happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_jobs
      Array.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_jobs
    assert_response :success
    assert_template :list_jobs
    assert_template layout: "layouts/application"
    assert_nil assigns(:vaults_list)
  end

  test "should get list_jobs with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_jobs
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_jobs
    assert_response :redirect
    assert_redirected_to "/500.html"
  end

  test "should get new_vault happy day" do
    glacier_facade = glacier_facade_default
    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :new_vault
    assert_response :success
    assert_template :new_vault
    assert_template layout: "layouts/application"
  end

  test "should get create_vault happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.create_vault vault_name
      String.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    post :create_vault
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "New vault was successfully created", flash[:notice]
  end

  test "should get destroy_vault happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.delete_vault vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :destroy_vault, id: "vault_test"
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "Vault was successfully deleted", flash[:notice]
  end

  test "should get inventory_retrieval happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_retrieval vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :inventory_retrieval, id: "vault_test"
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "Job for inventory retrieval was successfully created", flash[:notice]
  end

  test "should get inventory_download happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_download job_id, vault_name
      output = Aws::Glacier::Types::GetJobOutputOutput.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :inventory_download, id: job_id_default, vault: "arn:aws:glacier:us-west-2:280517293289:vaults/vault_test"
    assert_response :success
  end

  test "should get new_archive happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_vaults
      Array.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :new_archive
    assert_response :success
    assert_template :new_archive
    assert_template layout: "layouts/application"
    assert_equal Array.new, assigns(:list_names)
  end

  test "should get upload_archive happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.upload_archive vault_name, archive_description, file
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    post :upload_archive, vault_name: "vault_test", archive_description: "archive description", file: String.new("teste")
    assert_response :redirect
    assert_redirected_to glacier_new_archive_path
    assert_equal "Archive was successfully uploaded", flash[:notice]
  end

  private
     def glacier_facade_default
       GlacierFacade.new access_key_id_default, secret_access_key_default, region_default
     end

     def access_configuration_default
       glacier_facade = glacier_facade_default
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

     def job_id_default
       "qoeDCFVBFhtSn4Y14LF9fb_n_oO-yJ33pXRFxCzQJK6dZ-Ov892Dk0RgESCduTn-ChVAci_VD0U1nSiGvEPZT509tVM5"
     end
end
