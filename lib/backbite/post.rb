#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'backbite/post/postfilter'

module Backbite

  # Posts handles access to the different Posts in our Repository.
  class Posts < Array
    
    attr_reader :tlog

    def next_id
      self.size+1
    end
    
    def initialize(tlog)
      @tlog = tlog
      read
    end
    
    def with_export(type, params = { })
      const = Post::Export.const_get(type.to_s.upcase)
      map{ |post|
        post.with_export(const, params)
      }
    end
    
    def filter(params, &blk)
      ret = Filter.select(params, self) #.by_date!.reverse
      ret.each(&blk) if block_given?
      ret
    end

    def by_date!
      self.replace(sort_by{ |po| po.metadata[:date] })
    end

    def by_id!
      self.replace(sort_by{ |po| po.pid })
    end
    
    def update!
      read
    end

    def read(what = :spool)
      postfiles = (par = tlog.repository.join(what)).entries.
        reject{ |e| e.to_s =~ /^\.+/ }
      postfiles.inject(self) { |mem, f|
        postway = Post::Ways.dispatch(:yaml) { |way|
          way.tlog   = self.tlog
          way.source = YAML::load(par.join(f).readlines.join)
        }.process
        mem << postway
      }.with_ids
    end
    private :read

    def with_ids
      # i = -1
      # replace(self.map{ |pst| pst.pid = i+=1 and pst })
      # each(&blk) if block_given?
      # self
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
    
    attr_reader   :component
    attr_reader   :pid
    attr_accessor :neighbors

    def author
       metadata[:author] or tlog.author
    end

    def with_export(const, params)
      npost = dup.extend(const)
      npost.setup!(params)
      npost
    end

    def pid
      metadata[:pid]
    end
    
    # def pid=(pid)
    #   @pid = pid
    #   identifier and pid
    # end
    
    def <=>(o)
      metadata[:date] <=> o.date
    end
    
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

    def url
      df = metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
      "/archive/#{df}/##{identifier}"
    end
    
    def to_s
      prfx = "\n  "
      adds = [[:pid, pid], [:ident, identifier], [:url, url]]
      adds = adds.map{ |an,av| "#{an.to_s.upcase.yellow}: #{av.to_s.cyan}"}.join(";  #{"".bold.green}")
      ret = "#{name.to_s.capitalize.white.bold} #{"[".red} #{prfx}" <<
        fields.inject([]) { |m, field|
        m << if field.value.to_s.empty? then nil else field.to_s(10) end
      }.compact.join("#{prfx}") << "\n#{"]".red} #{"".bold.green}#{adds}"
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
        # we only need the name
        @component = params.delete(:component)
        params[:component] = @component.name

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
        self[:pid]  = @component.tlog.posts.next_id
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
      
      def self.input_fields(org)
        InputFields.new(org)
      end

      def self.input_styles(org)
        InputStyles.new(org)
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

        def predefined
          @predefined = definitions[:value] || ''
        end

        def apply_markup(markup, str)
          case markup
          when :redcloth
            require 'redcloth'
            RedCloth.new(str).to_html
          else
            str
          end
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

      class Inputs < Hash
        attr_reader :config
        def initialize(org)
          @config = org
        end

        def order
          @config.ordered
        end

        def sort
          @config.sort
        end
      end

      class InputFields < Inputs # :nodoc: All
      end

      class InputStyles < Inputs # :nodoc: All
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
