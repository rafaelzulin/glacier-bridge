class GlacierFacade
  include Enums

  def initialize access_key_id, secret_access_key, region_value
    @region = GlacierRegions.value_of region_value

    credentials = Aws::Credentials.new access_key_id, secret_access_key
    #TODO Add logger in the client
    @glacier_client = Aws::Glacier::Client.new(region: @region.value, ssl_verify_peer: false, credentials: credentials ) #http_wire_trace: true, logger(Logger)
  end

  def region_description
    @region.description
  end

  #TODO Colocar paginação quando houverem mais que 'x' elementos
  def list_vaults
    begin
      @glacier_client.list_vaults.vault_list.collect do | describe_vault |
        {
          vault_name: describe_vault.vault_name,
          vault_arn: describe_vault.vault_arn,
          size_in_bytes: describe_vault.size_in_bytes,
          number_of_archives: describe_vault.number_of_archives,
          creation_date: describe_vault.creation_date,
          last_inventory_date: describe_vault.last_inventory_date
        }
      end
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end

  end

  def list_jobs
    #TODO Colocar paginação
    #TODO Colocar filtro por status
    begin
      (list_vaults.collect do | describe_vault |
         @glacier_client.list_jobs(account_id: '-', vault_name: describe_vault[:vault_name]).job_list.collect do | job_description |
           {
              job_id: job_description.job_id,
              job_description: job_description.job_description,
              action: JobAction.value_of(job_description.action),
              archive_id: job_description.archive_id,
              vault_arn: job_description.vault_arn,
              vault_name: extract_vault_name(job_description.vault_arn),
              creation_date: job_description.creation_date,
              completed: job_description.completed,
              status_code: JobStatusCode.value_of(job_description.status_code),
              status_message: job_description.status_message,
              archive_size_in_bytes: job_description.archive_size_in_bytes,
              inventory_size_in_bytes: job_description.inventory_size_in_bytes,
              sns_topic: job_description.sns_topic,
              completion_date: job_description.completion_date,
              sha256_tree_hash: job_description.sha256_tree_hash,
              archive_sha256_tree_hash: job_description.archive_sha256_tree_hash,
              retrieval_byte_range: job_description.retrieval_byte_range,
              inventory_retrieval_parameters: {
                format: JobFormat.value_of(job_description.inventory_retrieval_parameters.format),
                start_date: job_description.inventory_retrieval_parameters.start_date,
                end_date: job_description.inventory_retrieval_parameters.end_date,
                limit: job_description.inventory_retrieval_parameters.limit,
                marker: job_description.inventory_retrieval_parameters.marker
              }
            }
        end
      end).flatten 1
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end
  end

  def create_vault vault_name
    begin
      @glacier_client.create_vault(vault_name: vault_name, account_id: '-')
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end
  end

  def delete_vault vault_name
    begin
      @glacier_client.delete_vault(vault_name: vault_name, account_id: '-', )
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end
  end

  def inventory_retrieval vault_name
    #TODO Tratar retorno da AWS
    begin
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
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end
  end

  def inventory_download job_id, vault_name
    begin
      body_io = @glacier_client.get_job_output({
        account_id: '-',
        vault_name: vault_name,
        job_id: job_id
      }).body
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end

    str_return = String.new
    body_io.each { |line| str_return = str_return + line } unless body_io.nil?
    return str_return
  end

  def upload_archive vault_name, archive_description, file
    begin
      @glacier_client.upload_archive({
        account_id: '-',
        vault_name: vault_name,
        archive_description: archive_description,
        body: file.tempfile
      })
    rescue Aws::Glacier::Errors::ServiceError => e
      raise Bridge::Errors::AwsException, e.message
    end
  end

  private
  def extract_vault_name vault_arn
    vault_arn[vault_arn.index('/') + 1, vault_arn.length]
  end
end
