$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require 'fileutils'
require 'message_observers'

class MessageObserversTest < Test::Unit::TestCase
  
  include FileUtils
  
  def setup
    @directory = File.join(File.dirname(__FILE__), '..', 'messages')
  end
  
  def teardown
    rm_r(@directory) if File.exists?(@directory)
  end
  
  def test_directory_is_created_when_directory_is_not_present
    file_observer = FileMessageObserver.new(@directory)
    
    assert File.exists?(@directory)
  end
  
  def test_if_directory_is_already_present_observer_can_still_be_created
    mkdir_p(@directory)

    assert File.exists?(@directory)
    assert_not_nil FileMessageObserver.new(@directory)
  end
  
  def test_message_received_is_saved_to_message_directory
    file_observer = FileMessageObserver.new(@directory)
    file_observer.update "To: junk@junk.com\nFrom: junk2@junk2.com\nSubject: What's up\n\nHi"
    
    assert_one_new_file_added_to @directory
  end
  
  def test_message_is_saved_in_a_file_named_time_stamp_underscore_to_dot_txt
    file_observer = FileMessageObserver.new(@directory, TestSystemTime.new(1))
    file_observer.update "To: junk@junk.com\nFrom: junk2@junk2.com\nSubject: What's up\n\nHi"
    
    expected_file_name = File.join(@directory, "1_junk@junk.com.txt")
    
    assert File.exists?(expected_file_name)
  end
  
  def test_message_contents_are_saved_to_the_file
    message = "To: junk@junk.com\nFrom: junk2@junk2.com\nSubject: What's up\n\nHi"

    file_observer = FileMessageObserver.new(@directory, TestSystemTime.new(1))
    file_observer.update message
    
    expected_file_name = File.join(@directory, "1_junk@junk.com.txt")
    
    assert_equal read_file_contents_into_a_string(expected_file_name), message
  end
  
  def test_messages_are_saved_for_later_inspection
    message = "To: junk@junk.com\nFrom: junk2@junk2.com\nSubject: What's up\n\nHi"

    mail_observer = MailMessageObserver.new
    mail_observer.update message
    mail_observer.update message
    
    assert_equal 2, mail_observer.messages.size
  end
  
  def test_message_is_converted_to_tmail
    message = "To: junk@junk.com\nFrom: junk2@junk2.com\nSubject: What's up\n\nHi"

    mail_observer = MailMessageObserver.new
    mail_observer.update message
    
    assert_equal 'What\'s up', mail_observer.messages.first.subject
  end
  
  private
  
  def read_file_contents_into_a_string(file_name)
    File.open(file_name) {|file| file.readlines.join }
  end
  
  
  def assert_one_new_file_added_to(directory)
    number_of_dot_and_dot_dot_entries_in_a_directory_when_it_is_first_created = 2
    number_of_entries_with_one_file = number_of_dot_and_dot_dot_entries_in_a_directory_when_it_is_first_created + 1
    
    assert_equal number_of_entries_with_one_file, Dir.entries(@directory).size
  end
end

class TestSystemTime
  def initialize(time)
    @time = time
  end
  
  def current_time_in_seconds
    @time
  end
  
end