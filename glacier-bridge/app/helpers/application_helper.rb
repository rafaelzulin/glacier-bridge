module ApplicationHelper
  def validate_params! *parameters
    ret_hash = Hash.new
    fail_params = Array.new

    parameters.each do | each |
      param = params[each]

      unless param.nil? or param.strip.empty?
        ret_hash[each] = param.strip
      else
        fail_params.push each
      end
    end

    if fail_params.length > 0
      missing_params = String.new
      fail_params.each do | each |
        missing_params.concat "#{each} "
      end
      raise ActionController::ParameterMissing, "Required parameters are missing: #{missing_params.strip}"
    end

    return ret_hash
  end
end
