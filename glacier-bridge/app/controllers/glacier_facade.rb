class GlacierFacade
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
    #TODO Colocar paginação quando houverem mais que 'x' elementos
      @glacier_client.list_vaults.vault_list.collect do | describe_vault |
        Types::Glacier::DescribeVaultOutput.new vault_name: describe_vault.vault_name,
          vault_arn: describe_vault.vault_arn,
          size_in_bytes: describe_vault.size_in_bytes,
          number_of_archives: describe_vault.number_of_archives,
          creation_date: describe_vault.creation_date,
          last_inventory_date: describe_vault.last_inventory_date
    end
  end

  def list_jobs
    #TODO Replace each for collect or similar
    #TODO Colocar paginação
    #TODO Colocar filtro por status

    (list_vaults.collect do | describe_vault |
       @glacier_client.list_jobs(account_id: '-', vault_name: describe_vault.vault_name).job_list.collect do | job_description |
        Types::Glacier::JobDescription.new job_id: job_description.job_id,
          job_description: job_description.job_description,
          action: job_description.action,
          archive_id: job_description.archive_id,
          vault_arn: job_description.vault_arn,
          creation_date: job_description.creation_date,
          completed: job_description.completed,
          status_code: job_description.status_code,
          status_message: job_description.status_message,
          archive_size_in_bytes: job_description.archive_size_in_bytes,
          inventory_size_in_bytes: job_description.inventory_size_in_bytes,
          sns_topic: job_description.sns_topic,
          completion_date: job_description.completion_date,
          sha256_tree_hash: job_description.sha256_tree_hash,
          archive_sha256_tree_hash: job_description.archive_sha256_tree_hash,
          retrieval_byte_range: job_description.retrieval_byte_range,
          inventory_retrieval_parameters: {
            format: job_description.inventory_retrieval_parameters.format,
            start_date: job_description.inventory_retrieval_parameters.start_date,
            end_date: job_description.inventory_retrieval_parameters.end_date,
            limit: job_description.inventory_retrieval_parameters.limit,
            marker: job_description.inventory_retrieval_parameters.marker
          }
      end
    end).flatten 1
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
    @glacier_client.upload_archive({
      account_id: '-',
      vault_name: vault_name,
      archive_description: archive_description,
      body: file.tempfile
      })
  end
end
