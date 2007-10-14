#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Plugins < Array
    def [](o)
      select{|pl|
        pl.name.split('::').last.downcase.to_sym == o.to_sym
      }.shift
    end
  end
  
  class Plugin

    AutoFieldNames = [:before, :content, :after]
    
    attr_reader :tlog

    def prepare
      AutoFieldNames.each do |afn|
        if respond_to?(afn)
          r = send(afn)
          Debug << "sending message `#{afn}` to plugin #{name}; result is %iBytes" % r.to_s.size
          @result[afn] = r
        end
      end
      self
    end
    
    def name
      self.class.name.split('::').last.downcase
    end

    def result
      return @result.values.shift if @result.size == 1

      AutoFieldNames.inject([]) do |m, afn|
        m << @result[afn]
      end.join
    end

    alias :value :result
    
    def to_s
      "#{name}={ #{result} }"
    end
    
    def self.inherited(o)
      @@rets << o
    end

    def initialize(tlog)
      @result = { }
      @tlog = tlog
    end
    
    def self.load(plugin_file)
      @@rets = Plugins.new
      eval(File.open(plugin_file).readlines.to_s)
      @@rets.last
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
