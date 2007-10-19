$:.unshift(File.join(File.dirname(__FILE__), '..', 'vendor'))

require 'fileutils'
require 'tmail'

class FileMessageObserver
  include FileUtils
  
  def initialize(message_directory, system_time = SystemTime.new)
    @message_directory = message_directory
    @system_time = system_time
    mkdir_p(message_directory)
  end

  def update(message_string)
    mail = TMail::Mail.parse(message_string)
    
    file_name = File.join(@message_directory, "#{@system_time.current_time_in_seconds}_#{mail.to}.txt")    
    File.open(file_name, 'w') {|file| file << message_string }
  end
end

class MailMessageObserver
  attr_reader :messages

  def initialize
    @messages = []
  end
  
  def update(message_string)
    @messages << TMail::Mail.parse(message_string)
  end
  
end

class SystemTime
  def current_time_in_seconds
    Time.now.to_i
  end
end