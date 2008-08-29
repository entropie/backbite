#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module Script

      def self.generate(tlog, which)
        choose(tlog, which).generate
      end

      def self.choose(tlog, which)
        self.constants.grep(/#{which}/i).map{ |c| Script.const_get(c).new(tlog) }.shift
      end

      def self.mail(tlog)
        tlog.author
      end
      
      class Generator
        def file
          subject = Script.mail(@tlog)
          to, sub = '', ''
          @file = "#!/usr/bin/env ruby\n\nrequire 'readline'\n@data = #{ PP.pp(@data, '').to_s }\n\n"
          @file << "unless chunks = @data[section = ARGV.first.to_sym]\n  @data.each{|k,v| puts(\"%12s: %s\" % [k, v * \', \']) }\n  fail \"'\#{section}' is no valid section\"\nend"

          #subject, to = "polis #{section}", "entropie@ackro.org"
          if ARGV.size > 1
            to = "Subject: %s \#{which}"
            sub = Script.mail(@tlog)
          end
          @file << "\n"
          @file << "
File.open(file = \"/tmp/\#{section}.polis\", 'w+') do |io|
  chunks.each do |chunk|
    io.puts \"[\#{chunk}_start]\",
      Readline.readline(\"\#{chunk} > \", true).strip,
      \"[\#{chunk}_end]\"
  end
end
"
          # if ARGV.size > 1
          #   puts 1
          # end
          #system("mail -s '#{subject}' #{to} < #{file}")
          @file << "puts '','',str"
          @file
        end
        
        attr_reader :tlog
        def initialize(tlog)
          @tlog = tlog
        end

        def generate
          @data = { }
          @tlog.components.each do |comp|
            @data.merge!(Hash[comp.name, comp.fields.select{ |c| not c.interactive?}.map(&:to_sym)])
          end
          @data
          file
        end
        
      end
      
      class Posts < Generator
      end

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
