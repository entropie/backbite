#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Components is a place to hold the tumblog specific component files
  # (and load them if necessary).
  class Components < Array
    
    include Post::Ways
    
    # YAMLComponent is uesed to extend the component class to set the values for
    # we're getting from the YAML source.
    module YAMLComponent  # :nodoc: All
      def read(*a);    raise "read not available in YAML"    end
      def reread!(*a) ; raise "reread! not available in YAML" end
      #def post(*a);    raise "post not available in YAML"    end

      def map(source)
        self.source = source
        fields(true)
      end

    end


    def generate(tlog, name)
      file = tlog.repository.join('components', "#{name}.rb")
      res = Generators.generate(name, self.class)
      ::File.open(file.to_s, 'w+'){ |f| f.write(res) }
      file.to_s
    end

    # Loads every single component in +directory+, returns an
    # Components instance.
    def self.load(directory, tlog)
      ret = self.new
      td = Pathname.new(::File.expand_path(directory))
      td.entries.map do |comp|
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

      ComponentSyntaxError = Backbite::NastyDream(self)
      
      include Settings
      
      attr_accessor :tlog

      attr_reader   :name, :config, :config_save

      attr_accessor :source

      attr_accessor :metadata
      
      # creates the component
      def self.define(name, &blk)
        comp = Component.new(name)
        comp.read!(&blk)
      end

      def target
        config[:target].first
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
          @config[:fields].each do |field, defi|
            result = Post::Fields.select(field, defi, self)
            if @source and value = @source[field]
              result.value = value
            end
            @fields.push(result)
          end
          #@fields.push(*fields)
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
        post_way = Post::Ways.dispatch(params[:way]) do |pw|
          pw.tlog    = @tlog
          pw.fields  = fields
        end
        Info << "posting via #{post_way}"
        post_way.process(params, self)
        Info << "#{name} Finished"
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
          @plugins = Plugins.load_for_component(self)
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
        "Component::#{@name.to_s.capitalize} [#{@config[:fields].keys.join(', ')}]"
      end


      # returns true if +sym+ == <tt>self.name</tt>
      def ==(sym)
        @name == sym.to_sym
      end
      

      def initialize(name)
        @name = name
      end

      def to_s
        "#{("%-10s"%@name.to_s).capitalize.bold.white} #{"[".red}" +
          " #{"Plugins".yellow}:#{plugins.size.to_s.cyan}" +
          " #{"Fields".yellow}:(#{fields.map{ |f| [(f.is_a?(:plugin) ? 'p' : 'f'), f.to_sym.to_s] }.map{|i,n| "#{i.bold}:#{n.green.bold}"}.join(', ')}) #{"]".red}"
      end

      def setup!
        @config = with_default_plugins(config)
        reread!
      end
      
      # Wraps the config values to somewhat we can understand better here.
      def reread!
        @config.each do |ident, values|
          #values = values.to_hash if values.kind_of?(Helper::Dictionary)
          case ident
          when :fields
            (@config[ident] = Post::Fields.input_fields(values)).merge!(values)
          when :style
            (@config[ident] = Post::Fields.input_styles(values)).merge!(values)
          end
        end
      end

      
      def read!(&blk)
        config = Configuration.new(@name)
        config.setup(&blk)
        @config = config
        self
      end

      def with_default_plugins(cfg)
        if tlog.config[:defaults][:automatic] and
            aplugins = tlog.config[:defaults][:automatic][:plugins]
          aplugins = tlog.config[:defaults][:automatic][:plugins]
          aplugins.each do |plugin, value|
            name = "plugin_#{plugin.to_s}".to_sym
            unless value.kind_of?(Proc)
              value = lambda{ }
            end
            cfg[:fields][name].read(&value) if cfg[:fields][:name]
          end
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
