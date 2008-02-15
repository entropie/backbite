#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'net/smtp'

module Backbite
  module Helper

    module Mail
      def self.about(tlog = nil)
        str = ''

        exampleco  = tlog.components.sort_by{ rand }.first
        if tlog
          addr = tlog.config[:defaults][:mail][:address] rescue "<none defined>"
          str << "
Hello,\n\nthis is #{Backbite.version} with repos `#{tlog.name}' located at
<#{tlog.http_path.to_s}>.
This is a generated message to display a list of components belonging
to the repository #{tlog.name} you're able to post to.

To post to a component you need a list of fields
and content for 'em goes to [fieldname_start].*[fieldname_end] in
the mailbody. The subject of such a mail looks as
'#{tlog.name} <component_name>'

A short overview about available components will follow, for the
complete skeleton of a component send mail to
mailto:#{addr}?subject=\"polis skel <component_name>\"

Here is an random example of a skeleton `#{exampleco.name}', which should
carry the subject 'polis skel #{exampleco.name}'

#{gentext = Generators.generate(exampleco.to_sym, Generators[:post], tlog)}"
          s, GLOBALS[:colors] = GLOBALS[:colors], false
          str << "\n\nComponent list:\n"
          str << "Send Mail with Subject '#{tlog.name} skel <component_name>' to <#{addr}>\n\n"
          tlog.components.each do |co|
            str << "" << co.to_s << "\n"
            str << " Subject: #{tlog.name} skel #{co.to_sym}\n"
            str << " Fieldset: "
            str << co.fields.select{ |f| not f.interactive? }.map(&:to_sym).join(', ') << "\n\n"
          end
        end
        GLOBALS[:colors] = s
        str + ("\n" << " "*(60-addr.size) << "-- " << addr)
      end

      def mailto(subject, msg, to, tlog, from = 'backbite@particle.ackro.ath.cx')
        rt = tlog.config[:defaults][:mail][:address] rescue nil
        msgstr = %Q(From: #{from}\nTo: #{to}\nSubject: #{subject}\n#{"Reply-To: #{rt}" if rt}\n)
        Net::SMTP.start('localhost') do |smtp|
          smtp.send_message(msgstr + msg, from, to)
        end
        Info << "mailto: #{to} with #{subject.dump}"
        true
      rescue
        warn $!
      end
      module_function :mailto
      
    end

  end
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
