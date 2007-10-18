#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro
  
  class Post < Delegator

    attr_reader :component
    
    def initialize(component)
      @component = component
    end

    def __getobj__
      @component
    end

    
    
    # Every time we write a file to disk, we create a new Metadata
    # instance to save additional information about the nut.
    #
    # * component -- name of the component
    # * way -- the way the Post was created.
    # * date -- creation time
    class Metadata < Hash

      include Helper

      # +params+ must include <tt>:component</tt> and <tt>:way</tt>
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

      def self.select(field, defi, comp)
        target =
          case field.to_s
          when /^plugin_(.*)/
            Post::Fields::InputPlugin
          when /^input_(.*)/
            Post::Fields::InputField
          end.new
        target.name = field
        target.definitions = defi
        target.component = comp
        target
      end
      
      def self.input_fields
        InputFields.new
      end

      def self.input_styles
        InputStyles.new
      end

      # InputField represents a single field in a post.
      class InputField

        attr_accessor :name, :definitions, :component

        # <tt>is_a?</tt> accepts a symbol or a Classname, and returns
        # true if classname matches +fieldtype+
        def is_a?(fieldtype)
          if fieldtype.kind_of?(Symbol)
            true if self.class.name[/::(\w+)$/, 1].downcase =~ /#{fieldtype}$/
          elsif fieldtype.class == self.class
            true
          else
            false
          end
        end

        def initialize(name = nil, defi = nil, comp = nil)
          @name, @definitions, @component = name, defi, comp
        end

        # 
        def run(value, params, tlog)
          @__text__ = value
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


      # InputField represents a plugin connected to the field.
      class InputPlugin < InputField

        def run(params, tlog)
          @component.plugins[@name]
        end

      end
      

      class InputFields < Hash # :nodoc: All
      end


      class InputStyles < Hash # :nodoc: All
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
