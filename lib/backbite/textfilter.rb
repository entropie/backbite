#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # A Textfilter is connected to an export method and replaces values on
  # every field. The syntax to call a filter looks like:
  # <code>>>>name(arg, arg1, arg2..)</code> which calls the filter:
  # <tt>:name</tt>, with <tt>arg, arg1, arg2</tt> as arguments.
  #
  # You're able to use every method Posts serves you in the body of
  # your filter. An example filter may look like:
  #
  #  define_filter(:tag){ |str|
  #    %Q'<a href="#{path_deep}tags/#{str}.html">#{str}</a>'
  #  }
  class Textfilter < Delegator

    attr_accessor :post
    
    def __getobj__
      @post
    end
    
    class Filter

      attr_reader :name, :filter, :regexp
      
      def initialize(name, regexp, &blk)
        @name, @regexp = name, regexp
        @filter = blk
      end

      def apply(value)
        case value
        when String
          value.gsub!(regexp) do |m|
            nam, opts = $1.to_sym, $2
            args = if opts
              opts.split(',').map{ |s| s.strip }
            else
              []
            end
            Info << "Filter[#{@name}]: #{nam}:#{args.join(',')}"
            # FIXME: maybe
            args.map!{ |a| a.gsub(/(^\(|\)$)/, '') }
            @filter.call(*args)
          end
          value
        else
          value
        end
      end
      
    end
    
    InvalidSource = Backbite::NastyDream(self)
    include Helper::Image

    def [](o)
      @for[o]
    end
    
    def self.read(tlog)
      ret = new(tlog)
      ret.read
      ret
    end

    def read
      td = tlog.repository.join(:textfilter)
      td.entries.grep(/^[^\.]+/).map{ |f| td.join(f)}.each do |filterf|
        Debug << "textfilter read: #{filterf}"
        source = filterf.readlines.join
        begin
          @target = filterf.basename.to_s[0..-4].to_sym
          eval(source, send(:binding))
        rescue SyntaxError
          raise InvalidSource, $!.to_s
        end
      end
    end
    
    attr_reader :tlog
    
    def initialize(tlog)
      @tlog = tlog
    end

    def target(k)
      @for ||= { }
      @for[k] ||= { }
    end
    
    def apply_textfilter(post, t, hash = { })
      @post = post
      ret = { }
      hash.each_pair do |name, value|
        val = value
        target(t).each do |fname, filter|
          val = filter.apply(val)
        end
        ret[name] = val
      end
      hash.merge(ret)
    end
    alias :apply :apply_textfilter

    def regexp_for_filter(rx)
      maybe = "#{@target}regexp"
      send((respond_to?(maybe) ? maybe.to_sym : :mkregexp), rx)
    end
    
    def mkregexp(rx)
      />>>(#{rx.to_s})(\(.*\))?/
    end

    def define_filter(name, regexp = nil, &blk)
      regexp = Regexp.new(name.to_s) unless regexp
      filter = Filter.new(name, regexp_for_filter(regexp), &blk)
      target(@target)[name] = filter      
      Debug << "assimilated textfilter: #{name} in #{@target}"
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
