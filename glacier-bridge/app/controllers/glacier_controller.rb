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

    begin
      parameters = validate_params! :vault_name
      glacier_facade.create_vault parameters[:vault_name]
      redirect_to glacier_list_vaults_path, flash: { success: "New vault was successfully created" }
    rescue ActionController::ParameterMissing => e
      redirect_to glacier_new_vault_path, flash: {error: e.message }
    end
  end

  #delete 'glacier/destroy_vault/:id' => 'glacier#destroy_vault', as: :glacier_destroy_vault
  def destroy_vault
    puts "#{Date.today} [INFO] list_vaults"
    begin
      parameters = validate_params! :id
      glacier_facade.delete_vault parameters[:id]
      redirect_to glacier_list_vaults_path, flash: { success: "Vault was successfully deleted" }
    rescue ActionController::ParameterMissing => e
      redirect_to glacier_list_vaults_path, flash: { error: e.message }
    end
  end

  #get 'glacier/inventory_retrieval/:id' => 'glacier#inventory_retrieval', as: :glacier_inventory_retrieval
  def inventory_retrieval
    puts "#{Date.today} [INFO] inventory_retrieval"
    begin
      parameters = validate_params! :id
      glacier_facade.inventory_retrieval parameters[:id]
      redirect_to glacier_list_vaults_path, flash: { success: "Job for inventory retrieval was successfully created" }
    rescue ActionController::ParameterMissing => e
      redirect_to glacier_list_vaults_path, flash: { error: e.message }
    end
  end

  #get 'glacier/inventory_download/:id' => 'glacier#inventory_download', as: :glacier_inventory_download
  def inventory_download
    puts "#{Date.today} [INFO] inventory_download"
    begin
      parameters = validate_params! :id, :vault_name
      body_io = glacier_facade.inventory_download parameters[:id], parameters[:vault_name]
      send_data body_io, filename: "inventory_#{parameters[:vault_name]}.txt", type: "application/json"
    rescue ActionController::ParameterMissing => e
      redirect_to glacier_list_jobs_path, flash: { error: e.message }
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
