#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Plugins < Array
    def [](o)
      r = select{|pl|
        nam = o.to_s.gsub!(/^(plugin|input)_/, '') || o
        pl.name.split('::').last.downcase.to_sym == nam.to_sym
      }.shift
      r
    end
  end
  

  # Each user-defined plugin is a subclass of Plugin.
  #
  # In the plugin various attributes are available:
  # * +field+ -- the Field instance
  # * +tree+  -- the response stream
  #
  # Following methods are known (and will be called if necessary)
  # * content  -- The value of the plugin; no interaction is needed
  # * before   -- value *before* content
  # * after    -- value *after*  content
  # * filter   -- overall filter to modify contents during export
  # * *_filter -- filter which will be only applied for corresponding export variant, for example +html_filter+
  class Plugin

    AutoFieldNames = [:before, :content, :after]
    
    attr_reader :tlog

    attr_accessor :params
    attr_accessor :field, :tree, :component, :tlog

    def dispatch(way)
      if respond_to?(:input)
        @result ||= { }
        Info << " - Plugin[#{name}]#input"
        fcontent = send(:input)
        yield fcontent, self if block_given?
        @result[:content] = way.run(name, params)
      end

      if respond_to?(:transform) and @result[:content]
        @result[:content] = send(:transform, @result[:content])
        Info << " - Plugin#transform='#{@result[:content].inspect}'"
      end
    end

    def prepare
      AutoFieldNames.each do |afn|
        if respond_to?(afn)
          r = send(afn)
          Debug << " - Plugin[#{name}]##{afn}='#{r}'"
          @result[afn] = r
        end
      end
      self
    end
    
    def name
      self.class.name.split('::').last.downcase
    end

    def result
      return @result.values.shift if @result.to_s.size == 1

      AutoFieldNames.inject([]) do |m, afn|
        m << @result[afn]
      end.compact
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
      ts = plugin_file.basename.to_s[0..-4].to_sym
      @@rets ||= Plugins.new
      if ret = @@rets[ts]
        return ret
      end
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
