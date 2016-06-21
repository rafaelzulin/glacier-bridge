class WelcomeController < ApplicationController
  #TODO Mudar método de validação para apllication helper
  include ApplicationHelper

  #get welcome/index
  def index
    all_regions = GlacierRegions.all_regions

    @regions = Hash.new
    all_regions.each do | glacier_region |
      @regions[glacier_region.description] = glacier_region.value
    end
  end

  #post welcome/access_register
  def access_register
    puts "#{Date.today} [INFO] access_register"

    begin
      parameters = validate_params! :access_key_id, :secret_access_key, :region

      glacier_facade = GlacierFacade.new parameters[:access_key_id], parameters[:secret_access_key], parameters[:region]
      session_store request.session_options[:id], key = GLACIER_SESSION_KEY, value = glacier_facade

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
