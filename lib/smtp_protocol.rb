require 'observer'
require 'smtp_states'

class SmtpProtocol
  include Observable
  
  def SmtpProtocol.create
    initial_state = :init
    
    states = {
      :init => InitState.new, 
      :connect => ConnectState.new, 
      :connected => ConnectedState.new, 
      :read_mail => ReadMailState.new, 
      :quit => QuitState.new 
    }
    
    SmtpProtocol.new(initial_state, states)
  end

  def initialize(initial_state, states)
    states.each_value { |state| state.protocol = self }

    @states = states
    @state = @states[initial_state]
  end
  
  def state=(new_state)
    @state = @states[new_state]
  end
  
  def serve(io)
    @state.serve(io)
  end
  
  def new_message_received(message)
    changed
    notify_observers(message)
  end
  
end

