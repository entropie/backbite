#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'net/smtp'

module Backbite
  module Helper

    module Mail

      def mailto(subject, msg, to, from = 'backbite')
        msgstr = %Q(From: #{from}\nTo: #{to}\nSubject: #{subject}\n\n)
        Net::SMTP.start('localhost') do |smtp|
          smtp.send_message(msgstr + msg, to, from)
        end
      rescue
        warn $!
      end
      module_function :mailto
      
    end

  end
end

p Backbite::Helper::Mail.mailto('foo', 'bar', 'mit@particle', 'backbite')


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
