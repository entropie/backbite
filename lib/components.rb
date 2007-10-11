#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  # Components is a place to hold the tumblog specific component files
  # (and load them if necessary).
  class Components < Array


    # loads every single component in +directory+, returns an
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
    
  end

  # A component is a file with some declarations for fields and
  # plugins, and some default behaviors.
  class Component

    attr_accessor :tlog


    # creates the component
    def self.define(name, &blk)
      Component.new(name).read(&blk)
    end


    # eval +what+
    def self.read(what)
      eval(what.to_s)
    end

    
    # Maps the <tt>@config[:fields]</tt> declarations to find the
    # right class for the Field, runs the <tt>Ways.dispatcher</tt> to
    # choose a proper way.
    def post(params)
      @post_handler = @config[:fields].map do |field, defi|
        case field.to_s
        when /^plugin_(.*)/
          Post::InputPlugin.new($1, defi, self)
        when /^input_(.*)/
          Post::InputField.new($1, defi, self)
        end
      end
      w = Ways.dispatch(params[:way]) do |w|
        w.tlog    = @tlog
        w.handler = @post_handler
      end
      w.process(params, self)
      w
    end


    # Iterates through the fields. If +name+ is non nil, return
    # specific plugin, if +name+ is nil, return all the plugins which
    # are relevant for the current Component.
    def plugins(name = nil)
      plugins = @config[:fields].map{ |f|
        $1.to_sym if f.first.to_s =~ /^plugin_(.*)/
      }.compact
      
      @plugins ||= (tld = @tlog.repository.join('plugins')).
        entries.map do |pl|
        next if pl.to_s =~ /^\.+/
        if plugins.include?(pl.to_s[0..-4].to_sym)
          Plugin.load(tld.join(pl.to_s))
        end
      end.compact
      @plugins = Plugins.new.push(*@plugins)
      return @plugins.select{ |pl| pl.name == name }.first if name
      return @plugins
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

    
    def reread!
      @config.each do |ident, values|
        case ident
        when :fields
          (@config[ident] = Post::InputFields.new).merge!(values)
        when :style
          (@config[ident] = Post::InputStyles.new).merge!(values)
        end
      end
    end


    # Creates a Configurations instance, evalutes <tt>&blk</tt> and reformats
    # the fields.
    def read(&blk)
      @config = Configurations.new(@name)
      @config.setup(&blk)
      reread!
      self
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
