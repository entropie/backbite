#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Components < Array
    
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

    def [](obj)
      select { |comp| comp == obj }.first
    end
    
  end

  
  class Component

    attr_accessor :tlog
    
    def self.define(name, &blk)
      Component.new(name).read(&blk)
    end
    
    def self.read(what)
      eval(what.to_s)
    end

    def post(params)
      @post_handler = @config[:fields].map do |field, defi|
        case field.to_s
        when /^plugin_(.*)/
          Post::Plugin.new($1, defi, self)
        when /^input_(.*)/
          Post::Input.new($1, defi, self)
        end
      end
      w = Ways.dispatch(params[:way]) do |w|
        w.tlog    = @tlog
        w.handler = @post_handler
      end
      w.process(params)
      w.write
      w
    end

    def plugins(name = nil)
      plugins = @config[:fields].map{ |f|
        if f.first.to_s =~ /^plugin_(.*)/
          $1.to_sym
        end
      }.compact #.map{ |a| "#{a.to_s}.rb"}
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
          (@config[ident] = Post::Fields.new).merge!(values)
        when :style
          (@config[ident] = Post::Styles.new).merge!(values)
        end
      end
    end
    
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
