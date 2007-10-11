#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Ways
    class Way
      attr_accessor :handler
      attr_accessor :tlog
      attr_reader   :result
      
      def initialize
        @result = { }
      end
      
      def inspect
        "<#{self.class.name} Fields:#{handler.map{ |h| h.name }.join(',')}>"
      end

      def process(params)
        handler.each do |hand|
          @result[hand.name.to_sym] =
            if hand.class == Ackro::Post::Input
              run(hand, params)
            elsif hand.class == Ackro::Post::Plugin
              hand.run(params, tlog)
            end
        end
        @result
      end

    end

    class Array < Way
      def run(handler, params)
        params[:array].shift
      end
    end

    class Commandline < Array
      def run(handler, params)
        Readline.readline(' %20s>' % handler.name.to_s)
      end
    end

    class Editor < Array
    end
    
    def self.dispatch(way)
      ret = nil
      if const = const_get(way.to_s.capitalize)
        yield ret = const.new
      else
        raise "Sorry, way '#{way}' is unknown."
      end
      ret
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
