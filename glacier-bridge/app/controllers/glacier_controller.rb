class GlacierController < ApplicationController
  include GlacierHelper
  before_filter :validate_credentials
  @@client = nil

  def session_memory
    @print = Session.instance.print
  end

  def list_vaults
    puts "#{Date.today} [INFO] list_vaults"
    begin
      @vaults_list = get_vaults_list
    rescue Exception => e
      error_handle(e)
    end

    begin
      @job_list = Array.new
      @vaults_list.each do | describe_vault |
        @job_list.concat glacier_client.list_jobs(account_id: '-', vault_name: describe_vault.vault_name).job_list
      end
    rescue Exception => e
      error_handle e
    end
  end

  def new_vault
  end

  def create_vault
    vault_name = params["vault_name"]
    begin
      resp = glacier_client.create_vault(vault_name: vault_name, account_id: '-')
      redirect_to glacier_list_vaults_path, notice: "New vault was successfully created"
    rescue Exception => e
      error_handle e
    end
  end

  def destroy_vault
    puts "#{Date.today} [INFO] list_vaults"
    begin
      resp = glacier_client.delete_vault(account_id: '-', vault_name: params["id"])
      redirect_to glacier_list_vaults_path, notice: "Vault was successfully deleted."
    rescue Exception => e
      error_handle e
    end
  end

  def inventory_retrieval
    puts "#{Date.today} [INFO] inventory_retrieval"
    begin
      vault_name = params["id"]
      resp = glacier_client.initiate_job({
        account_id: '-',
        vault_name: vault_name,
        job_parameters: {
            type: "inventory-retrieval",
            description: "Inventory Retrieval for " + vault_name,
            format: "JSON",
            inventory_retrieval_parameters: {
              end_date: Time.now
            }
          }
        })
      puts resp.inspect
      redirect_to glacier_list_vaults_path, notice: "Job for inventory retrieval was successfully created."
    rescue Aws::Glacier::Errors::ResourceNotFoundException => e
      redirect_to glacier_list_vaults_path, notice: e.message
    rescue Exception => e
      error_handle e
    end
  end

  def inventory_download
    puts "#{Date.today} [INFO] inventory_download"
    begin
      job_id = params["id"]
      vault_arn = params["vault"]
      vault_name = vault_arn[vault_arn.index('/') + 1, vault_arn.length]
      resp = glacier_client.get_job_output({
        #response_target: "/public",
        account_id: '-',
        vault_name: vault_name,
        job_id: job_id
        })
      retorno = ""
      resp.body.each { |line| retorno = retorno + line }
      puts retorno
      send_data retorno, filename: "inventory.txt", type: "plain/text"
    rescue Aws::Glacier::Errors::BadRequest => e
      error_handle e
    end
  end

  def new_archive
    puts "#{Date.today} [INFO] new_archive"
    begin
      @list_names = Array.new
      get_vaults_list.each do |vault|
        @list_names.push vault.vault_name
      end
      puts @list_names.inspect
    rescue Exception => e
      error_handle e
    end
  end

  def upload_archive
    puts "#{Date.today} [INFO] upload_archive"
    begin
      params.require(:archive_description)
      params.require(:vault_name)
      params.require(:file)
#      params.permit(:archive_description, :vault_name, :file)

      archive_description = params[:archive_description]
      vault_name = params[:vault_name]
      file = params[:file]

      glacier_client.upload_archive({
        account_id: '-',
        vault_name: vault_name,
        archive_description: archive_description,
        body: file.tempfile
        })

      redirect_to glacier_new_archive_path, notice: "Archive was successfully uploaded"
    rescue ActionController::ParameterMissing => e
      puts e.message
      redirect_to :back, notice: "A parameter is missing"
    rescue Exception => e
      error_handle e
    end
  end

  private
  def glacier_client
    Session.instance.recover session[:session_id], key = :glacier_client
  end

  def error_handle(exception)
    puts exception.message
    puts exception.backtrace
    redirect_to "/500.html"
  end

  def get_vaults_list
    glacier_client.list_vaults.vault_list
  end

  def validate_credentials
    puts "#{Date.today} [INFO] validate_credentials"

    client = Session.instance.recover session[:session_id], :glacier_client
    if client.nil?
      redirect_to welcome_index_path
    else
      @region = Session.instance.recover session[:session_id], :region_description
    end
  end
end
