#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Posts handles access to the different Posts in our Repository.
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
                 :tags    => :optional,
                 :target  => :optional
                 )
      ret = self.dup
      # select Posts by Target
      if target = params[:target]
        ret.reject!{ |p|
          target != p.config[:target]
        }
      end

      # select Posts by IDs
      if ids = params[:ids]
        ids = [ids] unless ids.kind_of?(Array)
        ret.reject!{ |post|
          not ids.include?(post.pid)
        }
      end
      
      # select Posts by Tags
      if tags = params[:tags]
        ret.reject!{ |post|
          tags.map{ |t| true if post.tags.include?(t) }.compact.empty?
        }
      end

      
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
      
      #ret = Posts.new(tlog).push(*ret)
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
      i = -1
      postfiles.inject(self) { |mem, f|
        postway = Post::Ways.dispatch(:yaml) { |way|
          way.tlog = self.tlog
          way.source = YAML::load(par.join(f).readlines.join)
        }.process
        postway.pid = i+=1
        yield postway if block_given?
        mem << postway
      }
    end

  end
  
  class Post < Delegator
    
    # Export contains a list of Modules to extend the Post class. E.g.
    # to use the +:html+ way to export the Repository, you first need
    # to define a Repository::Export sublcass, named HTML, which
    # responds to :export, therein your ExportTree will be evaluated
    # and uses via +with_export+ the +to_foo+ method of the extend
    # Post instance.
    # 
    # Got it? nope? see lib/export/*.rb for examples.
    class Export
    end
    
    attr_reader :component
    attr_accessor :pid
    attr_accessor :neighbors
    

    def initialize(component)
      @component = component
    end
    
    def __getobj__
      @component
    end

    def identifier
      @identifier ||= "#{component.name}#{pid}"
    end
    

    # setup! sets various attributes on our Plugin instances.
    def setup!(params)
      params.extend(Helper::ParamHash).
        process!(:tree => :required, :path_deep => :optional)
      self.neighbors = [tlog.posts.filter( :ids => [pid-1] ),
                        tlog.posts.filter( :ids => [pid+1] )].
        map{ |n| n.first }
      component.metadata = metadata
      self.fields.each do |fld|
        if fld.respond_to?(:plugin)
          fld.plugin.field = fld
          fld.plugin.neighbors = self.neighbors
          fld.plugin.component = @component
          fld.plugin.tlog = @component.tlog
          fld.plugin.pid = self.pid
          fld.plugin.identifier = identifier
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
