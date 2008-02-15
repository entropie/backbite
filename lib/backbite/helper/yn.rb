#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module YN
      def yn?(p = 'y', s = 'n', prompt = "#{p.upcase}/#{s}>")
        return true if Backbite.globals.force?
        str = Readline.readline(prompt << " ")
        str = p if str.empty?
        str.strip =~ /^#{p}$/ and true
      rescue Interrupt
        false
      end
      module_function :yn?
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
