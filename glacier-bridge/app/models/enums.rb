module Enums
	class Enum
		attr_reader :value

		def initialize value
			@value = value
		end

		def self.values
			self.constants.collect do | each |
				 self.const_get each
			end
		end

		def self.value_of value
			self.values.detect do | each |
				each.value == value
			end
		end
	end

	class GlacierRegions < Enum
		attr_reader :description

		def initialize(description, value)
			@description = description
			@value = value
		end

		NORTH_VIRGINIA = self.new "US East (N. Virginia)", "us-east-1"
		NORTH_CALIFORNIA = self.new "US West (N. California)", "us-west-1"
		OREGON = self.new "US West (Oregon)", "us-west-2"
		MUMBAI = self new "Asia Pacific (Mumbai)", "ap-south-1"
		SEOUL = self.new "Asia Pacific (Seoul)", "ap-northeast-2"
		SYDNEY = self.new "Asia Pacific (Sydney)", "ap-southeast-2"
		TOKYO = self.new "Asia Pacific (Tokyo)", "ap-northeast-1"
		FRANKFURT = self.new "EU (Frankfurt)", "eu-central-1"
		IRELAND = self.new "EU (Ireland)", "eu-west-1"

		private_class_method :new
	end

	class JobAction < Enum

		ARCHIVE_RETRIEVAL = self.new "ArchiveRetrieval"
		INVENTORY_RETRIEVAL = self.new "InventoryRetrieval"

		private_class_method :new
	end

	class JobStatusCode < Enum

		IN_PROGRESS = self.new "InProgress"
		SUCCEEDED = self.new "Succeeded"
		FAILED = self.new "Failed"

		private_class_method :new
	end

	class JobFormat < Enum

		JSON = self.new "JSON"
		CSV = self.new "CSV"

		private_class_method :new
	end
end
