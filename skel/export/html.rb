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
      t = (res/"##{identifier}")
      return '' unless t
      t.append{ |h| h << "#{" "*6}"}
      ordered.each do |field|
        f, filtered = field.to_sym, field.apply_filter(:html)
        opts = { }

        # if hm = field.definitions[:markup][:html] and not hm.kind_of?(Hash)
        filtered = field.apply_markup(field.definitions[:markup][:html], filtered)
        # end
        
        opts[:tag] = field.definitions[:tag] unless
          field.definitions[:tag].to_s.empty?
        opts[:tag] ||= :div

        tag = opts[:tag]

        t.append{ |h|
          h << "\n#{" "*6}"
          h.send(tag, :class => field.to_sym) { |f| f.text(filtered.to_s)}
          h << "#{" "*6}"
        }
      end
      t.append{ |h| h << "\n#{" "*8}\n"}
      t
    end
  end

  module Repository::Export::HTML # :nodoc: All

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
        @file = 'index.html'
        title!
        meta!
        bstyles!(params)
        styles!(params)
        files!(params)
        body_nodes(params)
        independent_nodes
        @__result__ = to_html
      end
      

      # returns the html tree
      def to_html
        @hpricot.to_html
      end
      alias :to_s :to_html
      
      private

      def body # :yield: hpricot_body_node
        ord = @tlog.config[:html][:body].
          order.reject{ |o|
          Repository::IgnoredBodyFields.include?(o)
        }
        hp = nil
        unless ord
          Error << "w"
          #ord = @tlog.config[:html][:body].order
          return
        end
        ord.map! do |n|
          v = @tlog.config[:html][:body][n]
          (hp=(@hpricot/:body)).append do |h|
            h << " "*4
            tag = v[:tag]
            tag = :div if tag.empty?
            h.send(tag, :id => n) { |ha|
              ha << "\n#{" "*8}"
            }
            h << "\n\n"
          end
          n
        end

        thash = Hash[*hp.first.containers.map{ |c| [c.attributes[:id].to_sym, c] }.flatten]

        ord.each do |o|
          if indyp = (cnf=@tlog.config[:html][:body][o])[:plugin] and
              not indyp.kind_of?(Hash)
            Debug << "Independent plugin #{indyp} for #{o}"
            Plugins.independent(@hpricot, @tlog, { indyp => cnf}, @params) do |a|
              thash[o] << a.content
            end
          else
            cfg = @tlog.config[:html][:body][o]
            yield(o, thash[o], cfg)
          end
        end
        hp
      end
      

      def body_nodes(params)
        posts =
          if psopts = params[:postopts]
            tlog.posts.dup.filter(params.merge(psopts))
          else
            tlog.posts.dup
          end
        #p posts.map(&:identifier)
        params.delete(:ids)
        params.delete(:postopts)
        body do |name, hpe, cfg|
          psts = posts.by_date!.reverse.
            with_export(:html, params.merge(:tree => self, :target => name))

          if(mi = cfg[:items][:max]).kind_of?(Fixnum)
            psts = psts.first(mi)
          end
          psts.each do |post|
            next if name != post.config[:target]
            phtml = Cache("%s%s" % [@params[:path_deep], post.identifier]) {
              post.to_html(name).to_s
            }
            Debug << "#{@file}: body > #{name} received #{phtml.size} Bytes"
            hpe << phtml
          end
          hpe
        end
      end

      def plugin_node
      end
      
      def independent_nodes
        Plugin::AutoFieldNames.each do |af|
          tar = @tlog.config[:html][:body][:independent][af]
          Plugins.independent(@hpricot, @tlog, tar, @params) do |a|
            tag = a.class.const_defined?(:TAG) ? a.class.const_get(:TAG) : :div
            w = case af; when :before then :prepend; when :after then :append end
            res = Hpricot("\n    <div class=\"indy #{a.name}\" id=\"#{a.identifier}\">\n      #{a.result}\n    </div>" + "\n")
            (@hpricot/:body).prepend(res.to_s)
          end
        end
      end
      
      def make_tree
        ret = ''
        ret << doctype << "\n" << timestamp << "\n"
        ret << "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n\n"
        ret << "<head>\n</head>" << "\n"
        ret << "<body>\n\n</body>\n\n</html>"
      end


      def doctype
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-transitional.dtd\">\n"
      end

      def timestamp
        %Q(<!-- Generated: #{Time.now} -->)
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
        #ways = repository.export.ways
        alternate = tlog.http_path('atom.xml')
        
        (r=(@hpricot/:head)).append do |h|
          h << " "*4         
          h.meta('http-equiv' => "Content-Type",
                 :content => 'text/html; charset=utf-8')
          h << "\n"
          h << " "*4
          h.script(:charset => 'utf-8', :type => 'text-javascript')
          h << "\n"
          h << " "*4          
          h.link(:type => 'application/atom+XML', :rel => 'alternate', :href => alternate)
          h << "\n"
        end
      end


      def bstyles!(params)
        tl = tlog
        (@hpricot/:head).append do |h|
          dfs = [
                 [:base     , { :media => :screen } ],
                 [:generated, { :media => :screen } ]
          ]
          dfs.each{ |n, v|
            h << " "*4
            link(:href  => "#{params[:path_deep]}include/#{n}.css",
                 :media => v[:media],
                 :type  => "text/css",
                 :rel   => "stylesheet")
            h << "\n"
          }
        end
      end

      def styles!(params)
        tl = tlog
        (@hpricot/:head).append do |h|
          tl.config[:stylesheets][:screen].each{ |n|
            h << " "*4
            link(:href  => "#{params[:path_deep]}include/#{n}.css",
                 :media => :screen,
                 :type  => "text/css",
                 :rel   => "stylesheet")
            h << "\n"
          }
        end
      end

      def files!(params)
        tl = tlog
        (@hpricot/:head).append do |h|
          tl.config[:javascript][:files].each{ |n|
            h << " "*4
            script(:src => "#{params[:path_deep]}include/#{n}.js",
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
