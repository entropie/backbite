#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  # Responsible for re-mapping the fields, calling plugin stuff and
  # saving the nut in the right place.
  module Ways

    # Parent class for any old way to post to a tumblog.
    #
    class Way

      attr_accessor :handler
      attr_accessor :tlog

      attr_reader   :result
      attr_reader   :component
      
      def initialize
        @result = { }
      end
      
      def inspect
        "<#{self.class.name} Fields:#{handler.map{ |h| h.name }.join(',')}>"
      end

      # Parses the handler hash, and decides which Post class is
      # qualified to handle the field.
      #
      # If the field's a plugin, we're going to create an instance of
      # it (because we only want to work on a single plugin instance).
      def process(params, component)
        @component = component
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

      def write
        self
      end
      
    end

    class Array < Way
      def run(handler, params)
        params[:array].shift
      end
    end

    class Commandline < Way
      def run(handler, params)
        Readline.readline(' %20s>' % handler.name.to_s)
      end
    end

    class Editor < Way
    end
    
    def self.dispatch(way) # :yield: way.new
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
