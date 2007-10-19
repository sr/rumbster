$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'rumbster'
require 'net/smtp'
require 'gserver'


class RumbsterTest < Test::Unit::TestCase
  
  def setup
    @observer = RumbsterObserver.new
    @server = Rumbster.new(10025)
    @server.add_observer(@observer)
    
    @server.start
  end
  
  def teardown
    @server.stop
  end
  
  def test_single_receiver_message_sent_by_client_is_received_by_listener
    message = "From: <junk@junkster.com>\r\nTo: junk@junk.com\r\nSubject: hi\r\n\r\nThis is a test\r\n"
    to = 'his_address@example.com'
    send_message to, message 
        
    assert_equal message, @observer.message
  end
  
  def test_multiple_receiver_message_sent_by_client_is_received_by_listener
    message = "From: <junk@junkster.com>\r\nTo: junk@junk.com\r\nSubject: hi\r\n\r\nThis is a test\r\n"
    to = ['his_address@example.com', 'her_address@example.com']
    send_message to, message 
        
    assert_equal message, @observer.message
  end

  def test_multiple_receiver_messages_sent_by_client_are_received_by_listener
    message_1 = "From: <junk_1@junkster.com>\r\nTo: junk_1@junk.com\r\nSubject: hi\r\n\r\nThis is a test_1\r\n"
    to_1 = ['his_address_1@example.com', 'her_address_1@example.com']
    send_message to_1, message_1 

    assert_equal message_1, @observer.message

    message_2 = "From: <junk_2@junkster.com>\r\nTo: junk_2@junk.com\r\nSubject: hi\r\n\r\nThis is a test_2\r\n"
    to_2 = ['his_address_2@example.com', 'her_address_2@example.com']
    send_message to_2, message_2 
        
    assert_equal message_2, @observer.message
  end
  
  private

  def send_message(to, message)
    Net::SMTP.start('localhost', 10025) do |smtp|
      smtp.send_message message, 'your@mail.address', to
    end
  end
  
end

class RumbsterObserver
  attr_accessor :message
  
  def update(message)
    @message = message
  end
end