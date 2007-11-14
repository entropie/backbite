#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Repository::Export::HTML

    def self.export(tlog)
      tree = Tree.new(tlog)
      tree
    end
    
    class Tree

      attr_reader :tlog, :hpricot
      
      def initialize(tlog)
        @tlog = tlog
        @hpricot = Hpricot(make_tree)
        meta!
        styles!
        files!
      end

      def to_html
        @hpricot.to_html
      end
      alias :to_s :to_html
      
      def make_tree
        ret = ''
        ret << doctype << "\n"
        ret << "<html>\n\n"
        ret << "<head>\n</head>" << "\n"
        ret << "<body>\n\n</body>\n\n</html>"
      end

      def doctype
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\"DTD/xhtml1-transitional.dtd\">"
      end
      
      def meta!
        (r=(@hpricot/:head)).append do |h|
          h << " "*4          
          h.meta('http-equiv' => "Content-Type",
                 :content => 'text/html; charset=utf-8')
          h << "\n"
        end
      end

      # <link rel="alternate" type="application/atom+XML" href="atom.xml"/>

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
