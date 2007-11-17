#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Post

    class Export

      module HTML

        def fid
          "#{name}#{pid}"
        end
        
        def to_html(hpricot_node, name)
          ordered = tlog.components[self.metadata[:component]].order.dup
          ordered.map!{ |o|
            fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
            fields[fname]
          }
          target = hpricot_node.to_a.first

          res = Hpricot("<div class=\"#{self.name}\" id=\"#{fid}\">\n</div>" + "\n")
          t = (res/:div)
          t.append{ |h| h << "#{" "*8}"}
          ordered.each do |field|
            f, filtered = field.to_sym, field.apply_filter(:html)
            opts = { }
            opts[:tag] = field.definitions[:tag] unless
              field.definitions[:tag].empty?
            opts[:tag] ||= :div
            tag = opts[:tag]
            t.append{ |h|
              h << "#{" "*8}"          
              h.send(tag, filtered, :class => field.to_sym)
              h << "\n#{" "*8}"
            }
          end
          target << "\n#{" "*8}"
          target << t.to_html
          t
        end
        
      end

      
      module Repository::Export::HTML

        # mount point
        def self.export(tlog, params)
          Tree.new(tlog, params)
        end
        
        # Tree makes the basic (and valid) HTML frame and handles
        # the hpricot access.
        class Tree < Repository::ExportTree

          attr_reader :hpricot
          
          def initialize(tlog, params)
            super
            @hpricot = Hpricot(make_tree)
            title!
            meta!
            styles!
            files!
            body_nodes(params)
          end
          

          # returns the html tree
          def to_html
            @hpricot.to_html
          end
          alias :to_s :to_html
          

          private


          def body_nodes(params)
            interval = @tlog.config[:defaults][:export][:ways][:html][:interval]
            interval = ((Time.now-interval)/24/60/60).to_i
            body do |name, hpe|
              @tlog.posts(params[:postopts].
                          merge(:target => name)).
                with_export(:html, :tree => self) { |post|
                post.to_html(hpe, name)
              }
            end
          end

          def body # :yield: hpricot_body_node
            tl = tlog
            (hp=(@hpricot/:body)).append do |h|
              tl.config[:html][:body].each_pair do |n, v|
                next if n == :style
                h << " "*4
                tag = v[:tag]
                tag = :div if tag.empty?
                h.send(tag, :id => n){|ha|
                  ha << "\n#{" "*4}"
                }
                h << "\n\n"
              end
            end
            tl.config[:html][:body].each_pair { |n, v|
              tag = v[:tag]
              tag = :div if tag.empty?
              yield(n, (hp/tag))
            }
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
