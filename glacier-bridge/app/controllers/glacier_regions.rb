class GlacierRegions
	attr_accessor :description, :value

	def initialize(description, value)
		@description = description
		@value = value
	end

	NORTH_VIRGINIA = self.new "US East (N. Virginia)", "us-east-1"
	NORTH_CALIFORNIA = self.new "US West (N. California)", "us-west-1"
	OREGON = self.new "US West (Oregon)", "us-west-2"
	IRELAND = self.new "EU (Ireland)", "eu-west-1"
	FRANKFURT = self.new "EU (Frankfurt)", "eu-central-1"
	TOKYO = self.new "Asia Pacific (Tokyo)", "ap-northeast-1"
	SEOUL = self.new "Asia Pacific (Seoul)", "ap-northeast-2"
	SYDNEY = self.new "Asia Pacific (Sydney)", "ap-southeast-2"

	def self.all_regions
		ret_arr = Array.new
		self.constants.each do | region_name |
			ret_arr.push GlacierRegions.const_get region_name
		end
		return ret_arr
	end

  def self.region_by_value value
    return self.all_regions.detect do | each |
      each.value == value
    end
  end

	private_class_method :new
end
