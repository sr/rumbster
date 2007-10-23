Gem::Specification.new do |s|
  s.name = %q{rumbster}
  s.version = "1.0.0"
  s.date = %q{2007-10-22}
  s.summary = %q{Rumbster is a simple SMTP server that receives email sent from a SMTP client. Received emails are published to observers that have registered with Rumbster. There are currently two observers; FileMailObserver and MailMessageObserver.}
  s.email = %q{adam@esterlines.com}
  s.homepage = %q{http://rumbster.rubyforge.org/}
  s.rubyforge_project = %q{rumbster}
  s.description = %q{Rumbster is a simple SMTP server that receives email sent from a SMTP client. Received emails are published to observers that have registered with Rumbster. There are currently two observers; FileMailObserver and MailMessageObserver.}
  s.has_rdoc = true
  s.authors = ["Adam Esterline"]
  s.files = ["lib/message_observers.rb", "lib/rumbster.rb", "lib/smtp_protocol.rb", "lib/smtp_states.rb", "test/message_observers_test.rb", "test/rumbster_test.rb", "test/smtp_protocol_test.rb", "test/smtp_states_test.rb", "vendor/tmail/address.rb", "vendor/tmail/base64.rb", "vendor/tmail/compat.rb", "vendor/tmail/config.rb", "vendor/tmail/encode.rb", "vendor/tmail/header.rb", "vendor/tmail/info.rb", "vendor/tmail/loader.rb", "vendor/tmail/mail.rb", "vendor/tmail/mailbox.rb", "vendor/tmail/Makefile", "vendor/tmail/mbox.rb", "vendor/tmail/net.rb", "vendor/tmail/obsolete.rb", "vendor/tmail/parser.rb", "vendor/tmail/parser.y", "vendor/tmail/port.rb", "vendor/tmail/scanner.rb", "vendor/tmail/scanner_r.rb", "vendor/tmail/stringio.rb", "vendor/tmail/textutils.rb", "vendor/tmail/tmail.rb", "vendor/tmail/utils.rb", "vendor/tmail/.cvsignore", "vendor/tmail.rb", "COPYING", "Rakefile", "README"]
  s.test_files = ["test/message_observers_test.rb", "test/rumbster_test.rb", "test/smtp_protocol_test.rb", "test/smtp_states_test.rb"]
  s.rdoc_options = ["--title", "rumbster Documentation", "--main", "README", "-q"]
  s.extra_rdoc_files = ["README"]
end
