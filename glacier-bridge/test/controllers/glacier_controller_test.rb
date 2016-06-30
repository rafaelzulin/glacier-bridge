require 'test_helper'
include Enums

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
    assert_select "h1", "List of vaults"
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
    assert_select "h1", "List of vaults"
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
      Array.new.push Bridge::Types::Glacier::JobDescription.new(job_id: "6C-oiL2VsIWbyTLqzMyzIqUQAI_wxAfkgvxieE8naUD1V6enk3KxPOea01riIpyBzs-xoy-hOmducqJ0xNu6VZiMgWCS",
        job_description: "Inventory Retrieval for some vault",
        action: JobAction::INVENTORY_RETRIEVAL,
        archive_id: nil,
        vault_arn: "arn:aws:glacier:us-west-2:280517293289:vaults/default_vault",
        vault_name: "default_vault",
        creation_date: Time.new(2016, 06, 15, 02, 00, 00, "-03:00"),
        completed: false,
        status_code: JobStatusCode::IN_PROGRESS,
        status_message: nil,
        archive_size_in_bytes: nil,
        inventory_size_in_bytes: nil,
        sns_topic: nil,
        completion_date: nil,
        sha256_tree_hash: nil,
        archive_sha256_tree_hash: nil,
        retrieval_byte_range: nil,
        inventory_retrieval_parameters: {
          format: JobFormat::JSON,
          start_date: nil,
          end_date: nil,
          limit: nil,
          marker: nil
        })
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_jobs
    assert_response :success
    assert_template :list_jobs
    assert_template layout: layout_default
    assert_equal 1, assigns(:job_list).size
    assert_select "h1", "List of Jobs"
    assert_select "table thead tr th", 13
    assert_select "table tbody tr", 1
  end

  test "should get list_jobs whithout jobs" do
    glacier_facade = glacier_facade_default

    def glacier_facade.list_jobs
      Array.new
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :list_jobs
    assert_response :success
    assert_template :list_jobs
    assert_template layout: layout_default
    assert_equal 0, assigns(:job_list).size
    assert_select "h1", "List of Jobs"
    assert_select "table thead tr th", 13
    assert_select "table tbody tr", 0
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
    assert_template layout: layout_default
    assert_select "h1", count: 1, text: "Create a new vault"
    assert_select "a[class='btn btn-default'][href='/glacier/list_vaults']", count: 1, text: "Back"
    assert_select "form[method=post][action='/glacier/create_vault']", 1
    assert_select "input", count: 3 do
      assert_select "input[type=text][name=vault_name][placeholder='Vault Name'][required][autofocus]", count: 1
      assert_select "input[type=submit][value=Create]", count: 1
    end
  end

  test "should get create_vault happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.create_vault vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    post :create_vault, vault_name: "vault_name"
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "New vault was successfully created", flash[:success]
  end

  test "should get create_vault without vault name" do
    glacier_facade = glacier_facade_default
    session_store request.session_options[:id], :glacier_facade, glacier_facade

    post :create_vault
    assert_response :redirect
    assert_redirected_to glacier_new_vault_path
    assert_equal "param is missing or the value is empty: Required parameters are missing: vault_name", flash[:error]
  end

  test "should get create_vault with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.create_vault vault_name
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    post :create_vault, vault_name: "vault_name"
    assert_response :redirect
    assert_redirected_to "/500.html"
  end

  test "should delete destroy_vault happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.delete_vault vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :destroy_vault, id: "vault_test"
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "Vault was successfully deleted", flash[:success]
  end

  test "should delete destroy_vault with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.delete_vault vault_name
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :destroy_vault, id: "vault_test"
    assert_response :redirect
    assert_redirected_to "/500.html"
  end

  test "should get inventory_retrieval happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_retrieval vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :inventory_retrieval, id: "vault_test"
    assert_response :redirect
    assert_redirected_to glacier_list_vaults_path
    assert_equal "Job for inventory retrieval was successfully created", flash[:success]
  end

  test "should get inventory_retrieval with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_retrieval vault_name
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    delete :inventory_retrieval, id: "vault_test"
    assert_response :redirect
    assert_redirected_to "/500.html"
  end

  test "should get inventory_download happy day" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_download job_id, vault_name
      '{' +
      '  "VaultARN": "arn:aws:glacier:us-west-2:280517293289:vaults/VaultName",' +
      '  "InventoryDate": "2016-06-18T12:31:15Z",' +
      '  "ArchiveList": [' +
      '    {' +
      '      "ArchiveId": "GdEgO_6aPKC9ovhOfewqSNKTOZuDimGTJS8iPfl_Da67m8E015sOWVKveDS8r66cxM7_LMGLsKBV6vUCPOmk-ue1ojaopc2HUaSmLLh9XuNiboULwLBn-eQdTdR0Wz_mHO1ONpeRnA",'+
      '      "ArchiveDescription": "teste",' +
      '      "CreationDate": "2016-06-17T20:02:26Z",' +
      '      "Size": 58,' +
      '      "SHA256TreeHash": "94d0a49c47391b5250a7f81f5f26e7ac4873bdd1f3666fce47e18d116a00f083"' +
      '    }' +
      '  ]' +
      '}'
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :inventory_download, id: job_id_default, vault_name: "VaultName"
    assert_response :success
    assert_template nil
    assert_equal "application/json", response.content_type
    assert_equal invetory_default, (response.stream.each { |text| text })[0]
  end

  test "should get inventory_download with nil response" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_download job_id, vault_name
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :inventory_download, id: job_id_default, vault_name: "VaultName"
    assert_response :success
    assert_template nil
    assert_equal "application/json", response.content_type
    assert_equal String.new, (response.stream.each { |text| text })[0]
  end

  test "should get inventory_download with exception raised" do
    glacier_facade = glacier_facade_default

    def glacier_facade.inventory_download job_id, vault_name
      raise Bridge::Errors::AwsException, "Error on the request"
    end

    session_store request.session_options[:id], :glacier_facade, glacier_facade

    get :inventory_download, id: job_id_default, vault_name: "vaultTest"
    assert_response :redirect
    assert_redirected_to "/500.html"
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

    def invetory_default
      '{' +
      '  "VaultARN": "arn:aws:glacier:us-west-2:280517293289:vaults/VaultName",' +
      '  "InventoryDate": "2016-06-18T12:31:15Z",' +
      '  "ArchiveList": [' +
      '    {' +
      '      "ArchiveId": "GdEgO_6aPKC9ovhOfewqSNKTOZuDimGTJS8iPfl_Da67m8E015sOWVKveDS8r66cxM7_LMGLsKBV6vUCPOmk-ue1ojaopc2HUaSmLLh9XuNiboULwLBn-eQdTdR0Wz_mHO1ONpeRnA",'+
      '      "ArchiveDescription": "teste",' +
      '      "CreationDate": "2016-06-17T20:02:26Z",' +
      '      "Size": 58,' +
      '      "SHA256TreeHash": "94d0a49c47391b5250a7f81f5f26e7ac4873bdd1f3666fce47e18d116a00f083"' +
      '    }' +
      '  ]' +
      '}'
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
