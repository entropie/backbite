#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Post
    
    class Input
      attr_reader :name
      def initialize(name, defi, comp)
        @name, @defi, @comp = name, defi, comp
      end
    end

    class Plugin < Input
      attr_reader :name
      def initialize(name, defi, comp)
        @name, @defi, @comp = name, defi, comp
      end

      def run(params, tlog)
        p @comp.plugins
        p @comp.plugins.class
        @comp.plugins[@name]
      end
      
    end
    
    class Fields < Hash
    end

    class Styles < Hash
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
