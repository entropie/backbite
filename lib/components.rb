#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Components < Hash

    def self.load(directory)
      (td = Helper::File.ep(directory)).entries.map do |comp|
        next if comp.to_s =~ /^\.+/
        Component.read(td.join(comp).readlines)
      end.compact
    end
  end

  class Fields < Hash
    def inspect
      "Fields:"
    end
  end

  class Styles < Hash
  end
  
  class Component

    def inspect
      "<Component::#{@name.to_s.capitalize} [#{@config[:fields].keys.join(', ')}>"
    end
    
    def self.define(name, &blk)
      Component.new(name).read(&blk)
    end
    
    def self.get_binding
      binding
    end
    
    def self.read(what)
      eval(what.to_s)
    end

    def initialize(name)
      @name = name
    end

    def reread!
      @config.each do |ident, values|
        case ident
        when :fields
          (@config[ident] = Fields.new).merge!(values)
        when :style
          (@config[ident] = Styles.new).merge!(values)
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
