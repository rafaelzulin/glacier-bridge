module Types
  module Glacier
    class DescribeVaultOutput
      attr_reader :vault_name, :vault_arn, :size_in_bytes, :number_of_archives, :creation_date, :last_inventory_date

      def initialize hash
        @vault_name = hash[:vault_name]
        @vault_arn = hash[:vault_arn]
        @size_in_bytes = hash[:size_in_bytes]
        @number_of_archives = hash[:number_of_archives]
        @creation_date = hash[:creation_date]
        @last_inventory_date = hash[:last_inventory_date]
      end
    end

    class JobDescription
      attr_reader :job_id, :job_description, :action, :archive_id, :vault_arn, :creation_date, :completed, :status_code, :status_message, :archive_size_in_bytes, :inventory_size_in_bytes, :sns_topic, :completion_date, :sha256_tree_hash, :archive_sha256_tree_hash, :retrieval_byte_range, :inventory_retrieval_parameters

      def initialize hash
        @job_id = hash[:job_id]
        @job_description = hash[:job_description]
        @action = hash[:action]
        @archive_id = hash[:archive_id]
        @vault_arn = hash[:vault_arn]
        @creation_date = hash[:creation_date]
        @completed = hash[:completed]
        @status_code = hash[:status_code]
        @status_message = hash[:status_message]
        @archive_size_in_bytes = hash[:archive_size_in_bytes]
        @inventory_size_in_bytes = hash[:inventory_size_in_bytes]
        @sns_topic = hash[:sns_topic]
        @completion_date = hash[:completion_date]
        @sha256_tree_hash = hash[:sha256_tree_hash]
        @archive_sha256_tree_hash = hash[:archive_sha256_tree_hash]
        @retrieval_byte_range = hash[:retrieval_byte_range]
        @inventory_retrieval_parameters = InventoryRetrievalJobDescription.new hash[:inventory_retrieval_parameters]
      end
    end

    class InventoryRetrievalJobDescription
      attr_reader :format, :start_date, :end_date, :limit, :marker

      def initialize hash
        @format = hash[:format]
        @start_date = hash[:start_date]
        @end_date = hash[:end_date]
        @limit = hash[:limit]
        @marker = hash[:marker]
      end
    end
  end
end
