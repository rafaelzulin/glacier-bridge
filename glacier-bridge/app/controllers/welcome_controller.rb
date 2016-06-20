class WelcomeController < ApplicationController
  #TODO Mudar método de validação para apllication helper
  include GlacierHelper

  def index
    all_regions = GlacierRegions.all_regions

    @regions = Hash.new
    all_regions.each do | glacier_region |
      @regions[glacier_region.description] = glacier_region.value
    end
  end

  def access_register
    puts "#{Date.today} [INFO] access_register"

    begin
      parameters = validate_params! :access_key_id, :secret_access_key, :region
      credentials = Aws::Credentials.new parameters[:access_key_id], parameters[:secret_access_key]
      #TODO Add logger in the client
      glacier_client = Aws::Glacier::Client.new(region: parameters[:region], ssl_verify_peer: false, credentials: credentials ) #http_wire_trace: true, logger(Logger)

      glacier_region = GlacierRegions.region_by_value parameters[:region]
      #TODO Transformar a chave glacier_client em constante

      session_store session[:session_id], key = :glacier_client, value = glacier_client
      session_store session[:session_id], key = :region_description, value = glacier_region.description
      session_store session[:session_id], key = :region_value, value = glacier_region.value

      redirect_to glacier_list_vaults_path
    rescue ActionController::ParameterMissing => e
      redirect_to :back, notice: e.message
    rescue Exception => e
      puts e.message
      puts e.backtrace
      redirect_to :back, notice: e.message
    end
  end

  private
  def session_store session_id, key, value
    Session.instance.store session_id, key, value
  end
end
