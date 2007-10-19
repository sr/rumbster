class NotInitializedError < RuntimeError; end

module State
  attr_accessor :protocol
  
  def serve(io)
    raise NotInitializedError.new if @protocol.nil?
    
    service_request(io)
    @protocol.state = @next_state
    @protocol.serve(io)
  end  
end

module Messages
  
  def greeting(io)
    io.puts '220 ruby ESMTP'
  end
  
  def helo_response(io)
    io.puts '250 ruby'
  end
  
  def ok(io)
    io.puts '250 ok'
  end
  
  def go_ahead(io)
    io.puts '354 go ahead'
  end
  
  def goodbye(io)
    io.puts '221 ruby goodbye'
  end
  
end

class InitState
  
  include State, Messages
  
  def initialize(protocol = nil, next_state = :connect)
    @protocol = protocol
    @next_state = next_state
  end
  
  private
    
  def service_request(io)
    greeting(io)
  end
  
end

class ConnectState
  
  include State, Messages

  def initialize(protocol = nil, next_state = :connected)
    @protocol = protocol
    @next_state = next_state
  end
    
  private
  
  def service_request(io)
    read_client_helo(io)
    helo_response(io)
  end
  
  def read_client_helo(io)
    io.readline
  end
  
end

class ConnectedState
  
  include State, Messages
  
  def initialize(protocol = nil)
    @protocol = protocol
    @next_state = :connected
  end
  
  private
  
  def service_request(io)
    request = io.readline
    
    if request.strip.eql? "DATA"
      @next_state = :read_mail
      go_ahead(io)
    else
      ok(io)
    end
  end
  
end

class ReadMailState
  
  include State, Messages
  
  def initialize(protocol = nil)
    @protocol = protocol
    @next_state = :quit
  end
  
  private
  
  def service_request(io)
    message = read_message(io)
    @protocol.new_message_received(message)
    ok(io)
  end
  
  def not_end_of_message(line)
    not line.strip.eql?('.')
  end
  
  def read_message(io)
    message = ''
    
    line = io.readline
    while not_end_of_message(line)
      message << line
      line = io.readline
    end
    
    message
  end
  
end

class QuitState
  
  include Messages
  attr_accessor :protocol
  
  def initialize(protocol = nil)
    @protocol = protocol
  end
  
  def serve(io)
    raise NotInitializedError.new if @protocol.nil?
    
    read_quit(io)
    goodbye(io)
  end
  
  private
  
  def read_quit(io)
    io.readline    
  end
  
end