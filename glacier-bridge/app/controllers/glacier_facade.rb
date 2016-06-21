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

  def list_jobs
    #TODO Replace each for collect or similar
    job_list = Array.new
    list_vaults.each do | describe_vault |
      job_list.concat @glacier_client.list_jobs(account_id: '-', vault_name: describe_vault.vault_name).job_list
    end
    return job_list
  end

  def create_vault vault_name
    #TODO Tratar retorno do ceate_vault da AWS
    @glacier_client.create_vault(vault_name: vault_name, account_id: '-')
  end

  def delete_vault vault_name
    @glacier_client.delete_vault(vault_name: vault_name, account_id: '-', )
  end

  def inventory_retrieval vault_name
    #TODO Tratar retorno da AWS
    @glacier_client.initiate_job({
      account_id: '-',
      vault_name: vault_name,
      job_parameters: {
          type: "inventory-retrieval",
          #TODO Dar opção de editar a descrição do job
          description: "Inventory Retrieval for " + vault_name,
          #TODO Dar opção de selecionar o formato de retorno
          format: "JSON",
          inventory_retrieval_parameters: {
            #TODO Dar opção de escolher o intervalo de tempo
            end_date: Time.now
          }
        }
      })
  end

  def inventory_download job_id, vault_name
    @glacier_client.get_job_output({
      account_id: '-',
      vault_name: vault_name,
      job_id: job_id
      })
  end

  def upload_archive vault_name, archive_description, file
  end 
end
