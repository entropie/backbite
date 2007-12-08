#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Post::Export::HTML

    def to_html(name)
      ordered = tlog.components[self.metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }

      res = Hpricot("<div class=\"post #{self.name}\" id=\"#{identifier}\">\n</div>" + "\n")
      t = (res/:div)
      t.append{ |h| h << "#{" "*8}"}
      ordered.each do |field|
        f, filtered = field.to_sym, field.apply_filter(:html)
        opts = { }

        opts[:tag] = field.definitions[:tag] unless
          field.definitions[:tag].to_s.empty?
        opts[:tag] ||= :div

        tag = opts[:tag]

        t.append{ |h|
          h << "#{" "*8}"          
          h.send(tag, :class => field.to_sym) { |f| f.text(filtered)}
          h << "\n#{" "*8}"
        }
      end
      t.append{ |h| h << "\n#{" "*8}"}
      t
    end
  end

  module Repository::Export::HTML # :nodoc: All
    
    # mount point
    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      @tree.write unless params[:nowrite]
      @tree
    end
    
    # Tree makes the basic (and valid) HTML frame and handles
    # the hpricot access.
    class Tree < Repository::ExportTree

      include Helper::CacheAble
      
      attr_reader :hpricot
      
      def initialize(tlog, params)
        super
        @hpricot = Hpricot(make_tree)
        @params = params
        title!
        meta!
        styles!
        files!
        body_nodes(params)
        @file = 'index.html'
        @__result__ = to_html
      end
      

      # returns the html tree
      def to_html
        @hpricot.to_html
      end
      alias :to_s :to_html
      

      private


      def body_nodes(params)
        #posts = @tlog.posts.sort.reverse

        body do |name, hpe|
          pexp = @tlog.posts.
            filter(params[:postopts].merge(:target => name))
          pexp.with_export(:html, @params.merge(:tree => self)) { |post|
            hpe << Cache("%s%s" % [params[:path_deep], post.identifier]) { 
              r = post.to_html(name)
            }.to_s if hpe.attributes[:id].to_sym == post.config[:target]
          }
        end
      end

      def body # :yield: hpricot_body_node
        tl = tlog
        ord = tl.config[:html][:body].order
        (hp=(@hpricot/:body)).append do |h|
          ord.each do |n|
            v = tl.config[:html][:body][n]
            next if n == :style
            h << " "*4
            tag = v[:tag]
            tag = :div if tag.empty?
            h.send(tag, :id => n) { |ha|
              ha << "\n#{" "*4}"
            }
            h << "\n\n"
          end
        end

        ord.each do |o|
          (hp.first).containers.each do |co|
            next if o == :style
            next if co.attributes[:id] =! o
            yield(o, co)
          end
        end
      end

      def make_tree
        ret = ''
        ret << doctype << "\n"
        ret << "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n\n"
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
        p = @params
        (@hpricot/:head).append do |h|
          dfs = { :generated => { :media => :screen }, :base => { :media => :screen}}
          dfs.merge(tl.config[:stylesheets][:files]).each_pair{ |n, v|
            h << " "*4            
            link(:href => "#{p[:path_deep]}include/#{n}.css",
                 :media => v[:media],
                 :type => "text/css",
                 :rel => "stylesheet")
            h << "\n"
          }
        end
      end

      def files!
        tl = tlog
        p = @params          
        (@hpricot/:head).append do |h|
          tl.config[:javascript][:files].each{ |n|
            h << " "*4
            script(:src => "#{p[:path_deep]}include/#{n.first}.js",
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
