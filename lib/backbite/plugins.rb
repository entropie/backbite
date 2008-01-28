#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Plugins < Array

    
    def [](o)
      r = select{|pl|
        nam = o.to_s.gsub!(/^(plugin|input)_/, '') || o
        pl.name == nam.to_sym
      }.shift
      r
    end

    
    # loads all plugins for +comp+
    def self.load_for_component(comp)
      tlog = comp.tlog
      tld = tlog.repository.join('plugins')
      plugin_fields = comp.config[:fields].keys
      plugins = tld.entries.map do |pl|
        next if pl.to_s =~ /^\.+/
        npl = ("plugin_" + pl.to_s[0..-4]).to_sym
        if plugin_fields.include?(npl)
          Plugin.load(tld.join(pl.to_s))
        end
      end
      Plugins.new.push(*plugins.compact)
    end


    # loads independent named +name+ plugin for +tlog+
    def self.load_for_independent(tlog, name)
      tlg = tlog.repository.join('plugins').entries
      files = tlg.map(&:to_s).grep(/#{name}\.rb$/)
      ret = []
      files.each do |f|
        ret << Plugin.load(tlog.repository.join('plugins', f))
      end if files
      Plugins.new.push(*ret)
    end
    

    def self.result_for_independent(tree, tlog, conf, params = { })
      tars = []
      conf.each{ |plname, plvals|
        tars << load_for_independent(tlog, plname)
      }
      tars.flatten.map do |ip|
        ip = ip.new(tlog)
        ip.tree = tree
        ip.tlog = tlog
        ip.path_deep = params[:path_deep]
        ip.identifier =
          if ip.class.const_defined?(:ID)
            ip.class.const_get(:ID)
          else
            ip.name
          end
        yield(ip.prepare)
      end
    end


    class << self
      alias :independent :result_for_independent
    end
    

    # Each user-defined plugin is a subclass of Plugin.
    #
    # In the plugin various attributes are available:
    # * +input+ -- marks field as non-interaktive
    # * +tree+  -- the response stream
    # * +field+ -- the Field instance
    # * +component+ -- the Component instance
    # * +tlog+ -- the Tumblog instance
    # * +identifier+ -- a uniq name of the post
    # * +pid+ -- the post_id
    # * +path_deep+ -- the prefix path
    # * +neighbors+ -- an array consisting of the neighbor posts
    #
    # Following methods are known (and will be called if necessary)
    # * input -- undocumented
    # * transform!(str) -- modifies the input string (no attributes available)
    # * content  -- The value of the plugin; no interaction is needed
    # * before   -- value *before* content
    # * after    -- value *after*  content
    # * filter   -- overall filter to modify contents during export
    # * *_filter -- filter which will be only applied for corresponding export variant, for example +html_filter+
    class Plugin
      
      AutoFieldNames = [:before, :content, :after]

      include Helper::Builder

      # The params
      attr_accessor :params
      # The instance of the current field
      attr_accessor :field
      # The entire result parse-tree
      attr_accessor :tree
      # The component instance
      attr_accessor :component
      # The tlog instance
      attr_accessor :tlog
      # A uniq name, consisting of (component.name+pid)
      attr_accessor :identifier
      # The post id
      attr_accessor :pid

      attr_accessor :path_deep
      
      attr_accessor :neighbors

      def interactive?
        not respond_to?(:input)
      end
      
      # dispatch runs +input+ on the plugin during component evaluation,
      # so its basically used to hard-set the result values.
      def dispatch(field, way)
        @result ||= { }
        if respond_to?(:metadata_inject)
          nam = send(:metadata_inject)
          Info << " - Plugin[#{name}]#metadata_inject: value from #{nam}"
          md = way.metadata[nam]
          @result[:content] = md
        elsif respond_to?(:input)
          Info << " - Plugin[#{name}]#input"
          fcontent = send(:input)
          yield fcontent, self if block_given?
          @result[:content] = way.run(field, params)
        end

        if respond_to?(:transform!) and @result[:content]
          @result[:content] = send(:transform!, @result[:content])
          Info << " - Plugin#transform='#{@result[:content].inspect}'"
        end
      end

      def prepare
        AutoFieldNames.each do |afn|
          if respond_to?(afn) and not respond_to?(:metadata_inject)
            r = send(afn)
            Debug << " - Plugin[#{name}]##{afn}='#{r}'"
            @result[afn] = r
          end
        end
        self
      end
      
      def name
        self.class.name
      end

      def self.name
        to_s.split('::').last.downcase.to_sym
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
        @@rets << o if defined? @@rets
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


    class IndependentPlugin < Plugin
      AutoSubNames = [:at_start, :at_end]
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
