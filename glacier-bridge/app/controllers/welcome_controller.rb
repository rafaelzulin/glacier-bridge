class WelcomeController < ApplicationController
  def index
    @regions = {
      "US East (N. Virginia)" => "us-east-1",
      "US West (N. California)" => "us-west-1",
      "US West (Oregon)" => "us-west-2",
      "EU (Ireland)" => "eu-west-1",
      "EU (Frankfurt)" => "eu-central-1",
      "Asia Pacific (Tokyo)" => "ap-northeast-1",
      "Asia Pacific (Seoul)" => "ap-northeast-2",
      "Asia Pacific (Sydney)" => "ap-southeast-2"
    }
  end
end
