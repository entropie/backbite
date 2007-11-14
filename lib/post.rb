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

    def with_export(type, params)
      const = Post::Export.const_get(type.to_s.upcase)
      map{ |post|
        npost = post.extend(const)
        npost.setup!(params)
        yield npost
        npost
      }
    end
    
    def filter(params, &blk)
      params.extend(Helper::ParamHash).
        process!(
                 :between => :optional,
                 :ids     => :optional,
                 :tags    => :optional
                 )
      ret = self.dup

      # select Posts by metadata[:date
      if bet = params[:between]
        ret.reject!{ |p|
          if bet.kind_of?(Range)
            if bet.include?(p.metadata[:date])
              false
            else
              true
            end
          else
            Time.now.to_i-bet >= p.metadata[:date].to_i
          end
        }
      end
      # select Posts by Tags
      if tags = params[:tags]
        ret = ret.find{ |post|
          not tags.map{ |t| true if post.tags.include?(t) }.compact.empty?
        }
      end
      ret.each(&blk) if block_given?
      ret
    end

    def find
      select do |post|
        yield post
      end.sort_by{ |po| po.metadata[:date] }
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

    class Export
    end
    
    attr_reader :component
    
    def initialize(component)
      @component = component
    end

    def __getobj__
      @component
    end


    # +setup!+ sets various attributes on our Plugin instance.
    def setup!(params)
      params.extend(Helper::ParamHash).
        process!(:tree => :required)
      self.fields.each do |fld|
        if fld.respond_to?(:plugin)
          fld.plugin.field = fld
          fld.plugin.component = @component
          fld.plugin.tlog = @component.tlog
          params.each_pair do |pnam, pval|
            fld.plugin.send("#{pnam}=", pval)
          end
        end
      end
    end
    

    def method_missing(m, *args, &blk)
      if @component.fields.include?(m)
        @component.send(:fields)[m].value
      else
        super
      end
    end

    
    def inspect
      ret = "<Post::#{name.to_s.capitalize} #{metadata.inspect} [" <<
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
      def initialize(meta, params = { })
        @meta = meta
        params.extend(ParamHash).
          process!(:component => :required, :way => :required)
        replace(params)
        add_defaults
      end

      def inspect
        "(Meta: [#{keys.join(',')}])"
      end

      private
      def add_defaults
        if @meta
          Info << "Meta: merging #{ @meta.map{ |k,v| "#{k}=#{v}"}}"
          merge!(@meta)
        end
        self[:date] ||= Time.now
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

        def apply_filter(filter, def_filter = :filter)
          filter = "#{filter}_filter".to_sym
          if self.respond_to?(:plugin) and plugin
            if plugin.respond_to?(filter) && res = plugin.send(filter)
              Info << "Filter::#{ name }:#{filter}"
              return res
            elsif plugin.respond_to?(def_filter) && res = plugin.send(def_filter)
              Info << "Filter::#{ name }:#{filter}"
              return res
            end
            value
          end
          value
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

        def ==(name)
          name = name.to_s
          name.gsub!(/^(input|plugin)_(\w+)$/, '\2')
          to_sym == name.to_sym
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
