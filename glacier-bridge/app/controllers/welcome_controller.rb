class WelcomeController < ApplicationController
  #TODO Mudar método de validação para apllication helper
  include ApplicationHelper
  include Enums

  #get welcome/index
  def index
    @regions = Hash.new
    GlacierRegions.values.each do | glacier_region |
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
    rescue ParameterMissing => e
      redirect_to welcome_index_path, flash: { error: e.message }
    end
  end

  private
  def session_store session_id, key, value
    Session.instance.store session_id, key, value
  end
end
