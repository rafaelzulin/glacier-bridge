class GlacierController < ApplicationController
  include ApplicationHelper

  before_filter :validate_credentials
  rescue_from Bridge::Errors::AwsException, with: :error_handler

  #TODO Use logging feature properly
  #get 'glacier/list_vaults'
  def list_vaults
    puts "#{Time.now} [INFO] list_vaults"
    @vaults_list = glacier_facade.list_vaults
  end

  #get 'glacier/list_jobs'
  def list_jobs
    puts "#{Date.today} [INFO] list_jobs"
    @job_list = glacier_facade.list_jobs
  end

  #get 'glacier/new_vault'
  def new_vault
  end

  #post 'glacier/create_vault/:id', as: :glacier_create_vault
  def create_vault
    puts "#{Date.today} [INFO] create_vault"
    parameters = validate_params! :vault_name
    begin
      # puts glacier_facade.create_vault parameters[:vault_name]
      redirect_to glacier_list_vaults_path, flash: { success: "New vault was successfully created" }
    rescue ActionController::ParameterMissing => e
      redirect_to glacier_new_vault_path, flash: { error: e.message }
    end
  end

  #delete 'glacier/destroy_vault/:id' => 'glacier#destroy_vault', as: :glacier_destroy_vault
  def destroy_vault
    puts "#{Date.today} [INFO] list_vaults"
    begin
      #TODO Tratar parâmetro de entrada
      glacier_facade.delete_vault params["id"]
      redirect_to glacier_list_vaults_path, notice: "Vault was successfully deleted"
    rescue Exception => e
      error_handler e
    end
  end

  #get 'glacier/inventory_retrieval/:id' => 'glacier#inventory_retrieval', as: :glacier_inventory_retrieval
  def inventory_retrieval
    puts "#{Date.today} [INFO] inventory_retrieval"
    begin
      #TODO Tratar parametro
      glacier_facade.inventory_retrieval params["id"]
      redirect_to glacier_list_vaults_path, notice: "Job for inventory retrieval was successfully created"
    rescue Aws::Glacier::Errors::ResourceNotFoundException => e
      redirect_to glacier_list_vaults_path, notice: e.message
    rescue Exception => e
      error_handler e
    end
  end

  #get 'glacier/inventory_download/:id' => 'glacier#inventory_download', as: :glacier_inventory_download
  def inventory_download
    puts "#{Date.today} [INFO] inventory_download"
    begin
      #TODO Tratar parâmetros
      job_id = params["id"]
      vault_arn = params["vault"]
      vault_name = vault_arn[vault_arn.index('/') + 1, vault_arn.length]

      resp = glacier_facade.inventory_download job_id, vault_name

      retorno = ""

      resp.body.each { |line| retorno = retorno + line } unless resp.body.nil?
      send_data retorno, filename: "inventory.txt", type: "plain/text"
    rescue Aws::Glacier::Errors::BadRequest => e
      error_handler e
    end
  end

  #get 'glacier/new_archive'
  def new_archive
    puts "#{Date.today} [INFO] new_archive"
    begin
      @list_names = Array.new
      glacier_facade.list_vaults.each do |vault|
        @list_names.push vault.vault_name
      end
    rescue Exception => e
      error_handler e
    end
  end

  #post 'glacier/upload_archive'
  def upload_archive
    puts "#{Date.today} [INFO] upload_archive"
    begin
      #TODO Tratar parâmetros
      params.require(:archive_description)
      params.require(:vault_name)
      params.require(:file)

      archive_description = params[:archive_description]
      vault_name = params[:vault_name]
      file = params[:file]

      glacier_facade.upload_archive archive_description, vault_name, file

      redirect_to glacier_new_archive_path, notice: "Archive was successfully uploaded"
    rescue ActionController::ParameterMissing => e
      puts e.message
      redirect_to :back, notice: "A parameter is missing"
    rescue Exception => e
      error_handler e
    end
  end

private
  def glacier_facade
    Session.instance.recover request.session_options[:id], key = GLACIER_SESSION_KEY
  end

  def error_handler(exception)
    puts exception.message
    puts exception.backtrace
    redirect_to "/500.html"
  end

  #before_filter
  def validate_credentials
    puts "#{Date.today} [INFO] validate_credentials"

    if glacier_facade.nil?
      redirect_to welcome_index_path
    else
      @region = glacier_facade.region_description
    end
  end
end
