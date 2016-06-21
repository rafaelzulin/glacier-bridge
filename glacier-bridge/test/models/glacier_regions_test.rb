class GlacierRegionsTest < ActiveSupport::TestCase
  test "Glacier Rergions new method is private" do
    assert_raises NoMethodError do
       GlacierRegions.new
     end
  end

  test "Accessors are acessible" do
    north_virginia = GlacierRegions::NORTH_VIRGINIA
    assert_equal "US East (N. Virginia)", north_virginia.description, "The description is incorrect"
    assert_equal "us-east-1", north_virginia.value, "The value is incorrect"
  end

  test "Validates methods wich returns all regions as an array" do
    regions = GlacierRegions.all_regions
    assert_equal 8, regions.length, "Number of regions are incorrect"
    regions.each do |region|
      assert_kind_of GlacierRegions, region, "The type of the object should be GlacierRegions"
    end
  end

  test "Validates getting a regin by value" do
    assert_equal GlacierRegions::OREGON, GlacierRegions.region_by_value("us-west-2"), "The region returner is invalid"
  end
end
