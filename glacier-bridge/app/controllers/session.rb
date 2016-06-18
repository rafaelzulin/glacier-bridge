class Session
  @@instance = Session.new
  private_class_method :new

  def self.instance
    return @@instance
  end

  def store session_id, key, value
    puts "store: #{session_id}, #{key}, #{value}"
    initialize_session session_id
    @session[session_id][key] = value
  end

  def recover session_id, key
    puts "recover: #{session_id}, #{key}"
    initialize_session session_id
    @session[session_id][key]
  end
  #TODO Apagar as sessões antigas

  private
    def initialize_session session_id
      @session = Hash.new if @session.nil?
      @session[session_id] = Hash.new if @session[session_id].nil?
    end
end
