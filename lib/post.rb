#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Post

    class Metadata < Hash

      include Helper

      def initialize(params = { })
        params.extend(ParamHash).
          process!(:component => :required, :way => :required)
        replace(params)
        add_defaults
      end

      def inspect
        "<#{self[:component]}: #{keys.join(',')}>"
      end

      private
      def add_defaults
        self[:date] = Time.now
      end
    end
    
    class Fields

      def self.input_fields
        InputFields.new
      end

      def self.input_styles
        InputStyles.new
      end
      
      class InputField

        attr_reader :name

        def initialize(name, defi, comp)
          @name, @defi, @comp = name, defi, comp
        end

        def run(text, params, tlog)
          @__text__ = text
          self
        end

        def to_s
          "#{ name }='#{ @__text__}'"
        end

        def value
          @__text__
        end

        def value=(o)
          @__text__ = o
        end
        
      end


      class InputPlugin < InputField

        def run(params, tlog)
          @comp.plugins[@name]
        end

      end
      

      class InputFields < Hash ; end


      class InputStyles < Hash ; end


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
