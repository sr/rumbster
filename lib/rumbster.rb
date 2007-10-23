require 'gserver'
require 'smtp_protocol'

class Rumbster < GServer
  
  def initialize(port=25, *args)
    super(port, *args)
    
    @observers = []
  end
  
  def serve(io)
    protocol = SmtpProtocol.create
    @observers.each do |observer|
      protocol.add_observer(observer)
    end
    protocol.serve(io)
  end
  
  def add_observer(observer)
    @observers.push(observer)
  end
  
 end
