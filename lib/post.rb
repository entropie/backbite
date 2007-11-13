#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Posts < Array

    attr_reader :tlog
    
    def initialize(tlog)
      @tlog = tlog
      each
    end
    
    def filter(params, &blk)
      params.extend(Helper::ParamHash).
        process!(
                 :between => :optional,
                 :ids     => :optional,
                 :tags    => :optional
                 )
      each(&blk) if block_given?
      self
    end

    def find
      select do |post|
        yield post
      end
    end
    
    def each
      postfiles = (par = tlog.repository.join('spool')).entries.
        reject{ |e| e.to_s =~ /^\.+/ }
      postfiles.inject(self) { |mem, f|
        postway = Post::Ways.dispatch(:yaml) { |way|
          way.tlog = self.tlog
          way.source = YAML::load(par.join(f).readlines.join)
        }.process
        yield postway if block_given?
        mem << postway
      }
    end

  end
  
  class Post < Delegator

    attr_reader :component
    
    def initialize(component)
      @component = component
    end

    def __getobj__
      @component
    end

    def method_missing(m, *args, &blk)
      if @component.fields.include?(m)
        @component.send(:fields)[m].value
      else
        super
      end
    end
    
    def inspect
      ret = "<Post::#{name.to_s.capitalize} [" <<
        fields.inject([]) { |m, field|
        m << field.to_s
      }.join(', ') << "]>"
    end

    def to_s
      prfx = "\n   "
      ret = "#{name.to_s.capitalize} [#{prfx}" <<
        fields.inject([]) { |m, field|
        m << field.to_s(10)
      }.join(",#{prfx}") << "\n]"
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

        def to_sym
          ret = @name.to_s.gsub(/^(input|plugin)_(\w+)$/, '\2').to_sym
        end
        
        def to_s(prfx_size = 0)
          "%#{prfx_size}s:  '#{ value }'" % name.to_s[/_([a-zA-Z_]+)$/, 1]
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
          plugin = @component.plugins[@name].new(tlog)
          plugin.params = params
          plugin
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
