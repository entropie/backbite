#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  # Components is a place to hold the tumblog specific component files
  # (and load them if necessary).
  class Components < Array
    
    module YAMLComponent
      def read ;    raise "read not available in #{self}"    end
      def reread! ; raise "reread! not available in #{self}" end
      def post ;    raise "post not available in #{self}"    end

      def map(source)
        self.source = source
        fields
      end

    end

    
    # Loads every single component in +directory+, returns an
    # Components instance.
    def self.load(directory, tlog)
      ret = self.new
      (td = Helper::File.ep(directory)).entries.map do |comp|
        next if comp.to_s =~ /^\.+/
        comp = Component.read(td.join(comp).readlines)
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

      attr_reader   :name

      attr_accessor :source

      # creates the component
      def self.define(name, &blk)
        Component.new(name).read(&blk)
      end
      
      
      # eval +what+
      def self.read(what)
        eval(what.to_s)
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
      def fields(force = true)
        @fields = nil if force
        @fields ||= Post::Fields.new
        fields = @config[:fields].map do |field, defi|
          result = Post::Fields.select(field, defi, self)
          if @source and value = @source[field]
            result.value = value
          end
          result
        end
        @fields.push(*fields)
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
                   :string=> :optional)

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


      # Wraps the config values to somewhat we can understand better here.
      def reread!

        @config[:fields][:plugin_tags] ||= { }
        @config[:fields][:plugin_date] ||= { }
        
        @config.each do |ident, values|
          case ident
          when :fields
            (@config[ident] = Post::Fields.input_fields).merge!(values)
          when :style
            (@config[ident] = Post::Fields.input_styles).merge!(values)
          end
        end
      end

      
      # Creates a Configuration instance, evalutes <tt>&blk</tt> and reformats
      # the fields.
      def read(&blk)
        @config = Config::Configuration.new(@name)
        @config.setup(&blk)
        reread!
        self
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
