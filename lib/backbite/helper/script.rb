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
          @file = "#!/usr/bin/env ruby\n\nrequire 'readline'\n@data = #{ PP.pp(@data, '').to_s }\n\n"
          @file << "which = ARGV.shift.to_sym\n"
          #@file << "which = :blog\n"
          @file << 'str = "Subject: %s #{which}\nTo: %s\n"' % [tlog.name, Script.mail(@tlog)]
          @file << "\n"
          @file << '@data[which.to_sym].each {|f|
s=Readline.readline(f.to_s + " > ", true).strip
if s
str << "[#{f}_start]\n\n#{s}\n\n[#{f}_end]\n\n"
end

}' + "\n"
          @file << "puts '','',str"
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
