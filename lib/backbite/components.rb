#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Components is a place to hold the tumblog specific component files
  # (and load them if necessary).
  class Components < Array


    # YAMLComponent is uesed to extend the component class to set the values for
    # we're getting from the YAML source.
    module YAMLComponent
      def read(*a);    raise "read not available in YAML"    end
      def reread!(*a) ; raise "reread! not available in YAML" end
      def post(*a);    raise "post not available in YAML"    end

      def map(source)
        self.source = source
        fields(true)
      end

    end

    
    # Loads every single component in +directory+, returns an
    # Components instance.
    def self.load(directory, tlog)
      ret = self.new
      (td = Helper::File.ep(directory)).entries.map do |comp|
        next if comp.to_s =~ /^\.+/
        comp = Component.read(td.join(comp).readlines, tlog)
        comp.tlog = tlog
        ret << comp
      end
      ret
    end

    
    # Select component from list which matches +obj+.
    def [](obj)
      select { |comp| comp == obj }.first
    end
    
    # A component is a file with some declarations for fields and
    # plugins, and some default behaviors.
    class Component
      
      attr_accessor :tlog

      attr_reader   :name, :config, :config_save

      attr_accessor :source

      attr_accessor :metadata
      
      # creates the component
      def self.define(name, &blk)
        comp = Component.new(name)
        comp.read!(&blk)
      end
      
      
      # eval +what+
      def self.read(what, tlog)
        ret = eval(what.to_s)
        ret.tlog = tlog
        ret.setup!
        ret
      end
      
      # Returns a list of fields attached to the current Component.
      # The result is an array, containing a list of classes which
      # <tt>Post::Fields.select()</tt> selects for each Field
      # definition in the component config file.
      #
      # A special case is if <tt>@source[fieldname]</tt> returns a
      # value for the current fieldnamename, then the value will be
      # set.
      #
      # +force+ forces to not use cache.
      def fields(force = false)
        @fields = nil if force
        if not @fields
          @fields ||= Post::Fields.new
          fields = @config[:fields].map do |field, defi|
            result = Post::Fields.select(field, defi, self)
            if @source and value = @source[field]
              result.value = value
            end
            result
          end
          @fields.push(*fields)
        end
        #puts @fields.map{ |f| f.name}.join(',')
        @fields
      end

      
      # Maps the <tt>@config[:fields]</tt> declarations to find the
      # right class for the Field, runs the <tt>Ways.dispatcher</tt> to
      # choose a proper way.
      def post(params)
        params.extend(Helper::ParamHash).
          process!(:way   => :optional,
                   :to    => :optional,
                   :hash  => :optional,
                   :file  => :optional,
                   :meta  => :optional
                   )
        Info << "Post[#{name}]: posting via `#{params[:way]}` to (#{params[:to]})"
        post_way = Post::Ways.dispatch(params[:way]) do |pw|
          pw.tlog    = @tlog
          pw.fields  = fields
        end
        post_way.process(params, self)
        post_way
      end
      

      # Iterates through the fields and loads necessary files.
      #
      # If +name+ is non nil, return specific plugin, if +name+ is nil,
      # return all the plugins which are relevant for the current
      # Component. <tt>&blk</tt> is optional.
      def plugins(name = nil, force = false, &blk) # :yield: Plugin
        tld = @tlog.repository.join('plugins')
        if not @plugins or force
          plugin_fields = @config[:fields].map{ |f|
            f.first
          }.compact
          plugins = tld.entries.map do |pl|
            next if pl.to_s =~ /^\.+/
            npl = ("plugin_" + pl.to_s[0..-4]).to_sym
            if plugin_fields.include?(npl)
              Plugin.load(tld.join(pl.to_s))
            end
          end.compact
          @plugins = Plugins.new.push(*plugins)
        end

        if name
          ret = @plugins[name]
          yield ret if block_given?
          return ret
        elsif block_given?
          plugins.each(&blk)
        end

        @plugins
      end


      def to_post
        Post.new(self.dup)
      end
      

      def inspect
        "<Component::#{@name.to_s.capitalize} [#{@config[:fields].keys.join(', ')}>"
      end


      # returns true if +sym+ == <tt>self.name</tt>
      def ==(sym)
        @name == sym.to_sym
      end
      

      def initialize(name)
        @name = name
      end

      def to_s
        "#{@name.to_s.capitalize}  Plugins:#{plugins.size}  Fields:#{config[:fields].keys.map{ |f| f.to_s.split(/_/).last }.join(', ')}"
      end

      def setup!
        @order = @config[:fields].order
        @config = with_default_plugins(config)
        reread!
      end
      
      # Wraps the config values to somewhat we can understand better here.
      def reread!
        @config.each do |ident, values|
          case ident
          when :fields
            (@config[ident] = Post::Fields.input_fields(values)).merge!(values)
          when :style
            (@config[ident] = Post::Fields.input_styles(values)).merge!(values)
          end
        end
      end

      
      def read!(&blk)
        config = Config::Configuration.new(@name)
        config.setup(&blk)
        @config = config
        self
      end

      def order
        @order
      end
      
      def with_default_plugins(cfg)
        aplugins = tlog.config[:defaults][:automatic][:plugins]
        aplugins.order.each do |plugin|
          name = "plugin_#{plugin.to_s}".to_sym
          value = aplugins[plugin][:value]
          unless value.kind_of?(Proc)
            value = lambda{ }
          end
          @order = order.push(name).uniq
          cfg[:fields][name].read(&value)
        end
        cfg
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
