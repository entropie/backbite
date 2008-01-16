#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Backbite::Post

  class Fields < Array

    def [](name)
      select{ |f| f.to_sym == name.to_sym }.first
    end

    def include?(name)
      not self[name].nil?
    end
    
    def self.select(field, defi, comp)
      target =
        case field.to_s
        when /^plugin_(.*)/
          InputPlugin
        when /^input_(.*)/
          InputField
        end.new
      target.name = field
      target.definitions = defi
      target.component = comp
      target
    end

    def self.input_fields(org)
      InputFields.new(org)
    end

    def self.input_styles(org)
      InputStyles.new(org)
    end

    # InputField represents a single field in a post.
    class InputField  # :nodoc: All

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

      def predefined
        @predefined = definitions[:value] || ''
      end

      def apply_markup(type, str)
        # markup
        if definitions[:markup] and markup = definitions[:markup][type]
          return case markup
                 when :redcloth
                   require 'redcloth'
                   RedCloth.new(str).to_html
                 else
                   str
                 end
        end
        str
      end

      def has_filter?(filter)
        filter = "#{filter}_filter".to_sym
        respond_to?(:plugin) and plugin.respond_to?(filter)
      end
      
      def apply_filter(filter, def_filter = :filter)
        filter = "#{filter}_filter".to_sym
        if self.respond_to?(:plugin) and plugin
          if plugin.respond_to?(filter) && res = plugin.send(filter)
            return res
          elsif plugin.respond_to?(def_filter) && res = plugin.send(def_filter)
            return res
          end
        end
        value
      end

      def initialize(name = nil, defi = nil, comp = nil)
        @name, @definitions, @component = name, defi, comp
      end

      def run(value, params, tlog)
        @__text__ = value
        self
      end

      def to_sym
        ret = @name.to_s.gsub(/^(input|plugin)_(\w+)$/, '\2').to_sym
      end

      def ==(name)
        name = name.to_s
        name.gsub!(/^(input|plugin)_(\w+)$/, '\2')
        to_sym == name.to_sym
      end
      
      def to_s(prfx_size = 0)
        "%-#{prfx_size+13}s #{ value.to_s.inspect.white }" % name.to_s[/_([a-zA-Z_]+)$/, 1].upcase.yellow.bold
      end

      def value
        @__text__
      end

      def value=(o)
        @__text__ = o
      end

      def interactive?
        respond_to?(:plugin) and plugin.interactive?
      end
      
    end


    # InputField represents a plugin connected to the field.
    class InputPlugin < InputField  # :nodoc: All

      attr_reader :plugin

      def plugin
        @plugin ||= @component.plugins[@name].new(@component.tlog)
        @plugin
      end
      
      def run(params, tlog)
        plugin.params = params
        self
      end
    end

    class Inputs < Backbite::Helper::Dictionary  # :nodoc: All
      attr_reader :config
    end

    class InputFields < Inputs # :nodoc: All
    end

    class InputStyles < Inputs # :nodoc: All
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
