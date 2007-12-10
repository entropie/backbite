#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Post

    class Export

      module TXT
        
        def to_txt
          str = "#{metadata[:component].to_s.capitalize} {"
          ordered = tlog.components[metadata[:component]].order.dup
          ordered.map!{ |o|
            fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
            fields[fname]
          }
          ordered.inject(str) do |m, field|
            f, filtered = field.to_sym, field.apply_filter(:txt)
            m << "\n %-10s %s" % [f.to_s+':', filtered]
          end
          str << "\n}\n"
        end

      end
      

      module Repository::Export::TXT # :nodoc: All

        # mount point
        def self.export(tlog, params)
          @tree = Tree.new(tlog, params)
          @tree.write
          @tree
        end
        
        class Tree < Repository::ExportTree

          def initialize(tlog, params)
            super
            @file = 'plain.txt'
            from = "#{tlog.author[:name]} <#{ tlog.author[:email]}>"
            @str = "#\n# Title: #{params[:title]}\n# Generated at: #{timestamp}\n# By: #{from}\n#\n# URL: #{tlog.http_path}\n#\n\n"
            posts = @tlog.posts.by_date!.reverse.filter(params)
            posts.with_export(:txt, :tree => self).each{ |post|
              @str << post.to_txt << "\n"
            }
            @__result__ = @str
          end

          def to_s
            @__result__
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
