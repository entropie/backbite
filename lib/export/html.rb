#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Post::Export::HTML

    def filter(field)
      if field.respond_to?(:plugin)
        plugin = field.plugin
        plugin.field = field
        if plugin.respond_to?(:html_filter) and res = plugin.html_filter
          return res
        elsif plugin.respond_to?(:filter) and res = plugin.filter
          return res
        end
      end
      field.value
    end
    
    def to_html
      str = '{{{'
      ordered = tlog.components[self.metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }
      ordered.inject(str) do |m, field|
        f, filtered = field.to_sym, filter(field)
        m << "\n %-10s %s " % [f, filtered]
      end
    end
    
  end

  
  module Repository::Export::HTML

    # mount point
    def self.export(tlog, params)
      Tree.new(tlog, params)
    end
    
    # Tree makes the basic (and valid) HTML frame and handles
    # the hpricot access.
    class Tree

      attr_reader :tlog, :hpricot, :timestamp
      

      def initialize(tlog, params)
        @tlog, @params = tlog, params
        @timestamp = Time.new
        @hpricot = Hpricot(make_tree)
        title!
        meta!
        styles!
        files!
        body!
      end
      

      # returns the html tree
      def to_html
        @hpricot.to_html
      end
      alias :to_s :to_html
      

      private


      def body!
        tl = tlog
         (@hpricot/:body).append do |h|
          tl.config[:html][:body].each_pair do |n, v|
            h << " "*4
            tag = v[:tag]
            tag = :div if tag.empty?
            h.send(tag, :id => n){|ha| ha << "\n\n    "}
            h << "\n\n"
          end
        end
      end

      def make_tree
        ret = ''
        ret << doctype << "\n"
        ret << "<html>\n\n"
        ret << "<head>\n</head>" << "\n"
        ret << "<body>\n\n</body>\n\n</html>"
      end

      def doctype
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-transitional.dtd\">\n"
      end

      def title!
        t = @params[:title].to_s
        (@hpricot/:head).append do |h|
          h << " "*4
          h.title(t)
          h << "\n"
        end
      end

      def meta!
        (r=(@hpricot/:head)).append do |h|
          h << " "*4          
          h.meta('http-equiv' => "Content-Type",
                 :content => 'text/html; charset=utf-8')
          h << "\n"
        end
      end

      def styles!
        tl = tlog
        (@hpricot/:head).append do |h|
          tl.config[:stylesheets][:files].each_pair{ |n, v|
            h << " "*4            
            link(:src => tl.http_path("include/#{n}.css"),
                 :media => v[:media],
                 :type => "text/css",
                 :rel => "stylesheet")
            h << "\n"
          }
        end
      end

      def files!
        tl = tlog
        (@hpricot/:head).append do |h|
          tl.config[:javascript][:files].each{ |n|
            h << " "*4
            script(:src => tl.http_path("include/#{n.first}.js"),
                   :type => "text/javascript" )
            h << "\n"
          }
        end
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
