$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'smtp_protocol'

class SmtpProtocolTest < Test::Unit::TestCase
  
  def test_protocol_sets_protocol_property_on_each_state
    init_state = TestState.new
    
    protocol = SmtpProtocol.new(:init, {:init => init_state})

    assert_same protocol, init_state.protocol
  end
  
  def test_protocol_starts_in_the_initial_state
    init_state = TestState.new
    
    protocol = SmtpProtocol.new(:init, {:init => init_state})
    protocol.serve(nil)
    
    assert init_state.called
  end
  
  def test_state_is_changed_when_a_new_state_is_set
    next_state = TestState.new
    
    protocol = SmtpProtocol.new(:init, {:init => TestState.new, :next => next_state})
    protocol.state = :next
    protocol.serve(nil)
    
    assert next_state.called
  end
  
  def test_listeners_are_notified_when_a_new_message_is_received
    protocol = SmtpProtocol.new(:init, {:init => TestState.new})
    observer = TestObserver.new
    message = 'hi'
    
    protocol.add_observer(observer)
    
    protocol.new_message_received(message)
    
    assert_same message, observer.received_message
  end
  
end

class TestObserver
  attr_accessor :received_message
  
  def update(message)
    @received_message = message
  end
end

class TestState
  attr_accessor :called, :protocol
  
  def serve(io)
    @called = true
  end
  
end
