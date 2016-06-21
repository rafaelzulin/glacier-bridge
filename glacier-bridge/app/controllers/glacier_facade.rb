class GlacierFacade
  attr_accessor :glacier_client

  def initialize access_key_id, secret_access_key, region_value
    @region = GlacierRegions.region_by_value region_value

    credentials = Aws::Credentials.new access_key_id, secret_access_key
    #TODO Add logger in the client
    @glacier_client = Aws::Glacier::Client.new(region: @region.value, ssl_verify_peer: false, credentials: credentials ) #http_wire_trace: true, logger(Logger)
  end

  def region_description
    @region.description
  end

  def list_vaults
    @glacier_client.list_vaults.vault_list
  end
end
