$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'stringio'
require 'smtp_protocol'

class SmtpStatesTest < Test::Unit::TestCase
 
  def setup
    buffer = ''
    @server_stream = StringIO.new(buffer)
    @client_stream = StringIO.new(buffer)    
    @protocol = TestProtocol.new
  end
 
  def test_greeting_is_returned_upon_initial_client_connection
    init_state = InitState.new(@protocol)
    init_state.serve(@server_stream)
       
    assert_equal "220 ruby ESMTP\n", @client_stream.readline
  end
  
  def test_initial_state_passes_protocol_connect_as_the_next_state_in_the_chain
    init_state = InitState.new(@protocol)
    init_state.serve(@server_stream)
    
    assert_equal :connect, @protocol.state
  end
  
  def test_initial_state_passes_protocol_the_same_io_as_it_received
    init_state = InitState.new(@protocol)
    init_state.serve(@server_stream)
    
    assert_same @server_stream, @protocol.io
  end
  
  def test_initial_state_raises_not_initialized_when_protocol_is_not_set
    init_state = InitState.new
    
    assert_raise NotInitializedError do 
      init_state.serve(@server_stream)
    end
  end
     
  def test_helo_is_accepted_while_in_connect_state
    @client_stream.puts "HELO test.client"
    connect_state = ConnectState.new(@protocol)

    connect_state.serve(@server_stream)
    
    assert_equal "250 ruby\n", @client_stream.readline
  end
  
  def test_connect_state_passes_protocol_connected_as_the_next_state_in_the_chain
    @client_stream.puts "HELO test.client"
    connect_state = ConnectState.new(@protocol)

    connect_state.serve(@server_stream)
    
    assert_equal :connected, @protocol.state
  end
  
  def test_connect_state_passes_protocol_the_same_io_as_it_received
    @client_stream.puts "HELO test.client"
    connect_state = ConnectState.new(@protocol)

    connect_state.serve(@server_stream)
    
    assert_same @server_stream, @protocol.io
  end
  
  def test_connect_state_raises_not_initialized_when_protocol_is_not_set
    connect_state = ConnectState.new
    
    assert_raise NotInitializedError do
      connect_state.serve(@server_stream)
    end
  end
    
  def test_from_okayed_while_in_connected_state
    @client_stream.puts "MAIL FROM:<adam@esterlines.com>"
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal "250 ok\n", @client_stream.readline
  end
  
  def test_connected_state_passes_protocol_connected_as_the_next_state_when_client_sends_from_request
    @client_stream.puts "MAIL FROM:<junk@junkster.com>"
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal :connected, @protocol.state
  end
  
  def test_rcpt_okayed_while_in_connected_state
    @client_stream.puts "RCPT TO:<junk@junkster.com>"    
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal "250 ok\n", @client_stream.readline
  end
  
  def test_connected_state_passes_protocol_connected_as_the_next_state_when_client_sends_rcpt_request
    @client_stream.puts "RCPT TO:<foo@foo.com>"    
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal :connected, @protocol.state
  end
  
  def test_connected_state_passes_protocol_the_same_io_as_it_received
    @client_stream.puts "MAIL FROM:<foo@foo.com>"
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_same @server_stream, @protocol.io
  end
  
  def test_data_request_given_the_go_ahead_while_in_connected_state
    @client_stream.puts "DATA"
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal "354 go ahead\n", @client_stream.readline
  end
  
  def test_connected_state_passes_protocol_read_mail_as_the_next_state_when_client_sends_data_request
    @client_stream.puts "DATA"
    connected_state = ConnectedState.new(@protocol)

    connected_state.serve(@server_stream)
    
    assert_equal :read_mail, @protocol.state
  end
  
  def test_connected_state_raises_not_initialized_when_protocol_is_not_set
    connected_state = ConnectedState.new
    
    assert_raise NotInitializedError do
      connected_state.serve(@server_stream)
    end
  end
  
  def test_read_mail_state_reads_until_a_single_dot_is_found_on_a_line_then_returns_an_ok_message
    @client_stream.puts "To: junk@junk.com\nFrom: junk2@junk2.com\n\nHi\n.\n"
    read_mail_state = ReadMailState.new(@protocol)
    
    read_mail_state.serve(@server_stream)
    
    assert_equal "250 ok\n", @client_stream.readline
  end
  
  def test_read_mail_state_passes_read_message_to_protocol
    message = "To: junk@junk.com\nFrom: junk2@junk2.com\n\nHi\n"
    @client_stream.puts "#{message}.\n"
    read_mail_state = ReadMailState.new(@protocol)
    
    read_mail_state.serve(@server_stream)
    
    assert_equal message, @protocol.new_message
  end
  
  def test_read_mail_state_passes_protocol_quit_as_the_next_state_when_mail_message_is_read
    @client_stream.puts "To: junk@junk.com\nFrom: junk2@junk2.com\n\nHi\n.\n"
    read_mail_state = ReadMailState.new(@protocol)
    
    read_mail_state.serve(@server_stream)
    
    assert_equal :quit, @protocol.state
  end
  
  def test_read_mail_state_raises_not_initialized_when_protocol_is_not_set
    read_mail_state = ReadMailState.new
    
    assert_raise NotInitializedError do
      read_mail_state.serve(@server_stream)
    end
  end
  
  def test_quit_state_reads_client_quit_and_says_goodbye
    @client_stream.puts "QUIT"
    quit_state = QuitState.new(@protocol)
    
    quit_state.serve(@server_stream)
    
    assert_equal "221 ruby goodbye\n", @client_stream.readline
  end
  
  def test_quit_state_raises_not_initialized_when_protocol_is_not_set
    quit_state = QuitState.new
    
    assert_raise NotInitializedError do
      quit_state.serve(@server_stream)
    end
  end
  
end

class TestProtocol
  attr_accessor :state, :io
  attr_reader :new_message
  
  def serve (io)
    @io = io
  end
  
  def new_message_received(message)
    @new_message = message
  end
end