class SessionTest < ActiveSupport::TestCase
  setup do
    session_instance.reset
  end

  test "Session new method is private" do
    assert_raises NoMethodError do
      Session.new
    end
  end

  test "Session intance method return the same object" do
    assert_equal session_instance, session_instance, "The Session.instance method should return the same object"
  end

  test "Store and recover happy day" do
      session_instance.store "SessionId", "key", "value"
      returned_value = session_instance.recover "SessionId", "key"
      assert_equal "value", returned_value, "The value stored should be the same returned"
  end

  test "Store a different value with the same key" do
    session_instance.store "SessionId", "key", "value"
    returned_value = session_instance.recover "SessionId", "key"
    assert_equal "value", returned_value, "The value stored should be the same returned"

    session_instance.store "SessionId", "key", "value2"
    returned_value = session_instance.recover "SessionId", "key"
    assert_equal "value2", returned_value, "The value stored should be the same returned"
  end

  test "Validates setting a key to nil value" do
    session_instance.store "SessionId", "key", "value"
    returned_value = session_instance.recover "SessionId", "key"
    assert_equal "value", returned_value, "The value stored should be the same returned"

    session_instance.store "SessionId", "key", value = nil
    returned_value = session_instance.recover "SessionId", "key"
    assert_nil returned_value, "The value returned should be nil"
  end

  test "Setting a value without a key" do
    session_instance.store "SessionId", nil, "value"
    returned_value = session_instance.recover "SessionId", nil
    assert_nil returned_value, "The value returned should be nil"
  end

  test "Setting a key/value pair without a session id" do
    session_instance.store nil, "key", "value"
    returned_value = session_instance.recover nil, "key"
    assert_nil returned_value, "The value returned should be nil"
  end

  private
  def session_instance
    Session.instance
  end
end
