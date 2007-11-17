#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Post

    class Export

      module TXT
        
        def to_txt
          str = '{{{'
          ordered = tlog.components[self.metadata[:component]].order.dup
          ordered.map!{ |o|
            fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
            fields[fname]
          }
          ordered.inject(str) do |m, field|
            f, filtered = field.to_sym, field.apply_filter(:txt)
            m << "\n %-10s %s " % [f, filtered]
          end
        end

      end
      

      module Repository::Export::TXT

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
            @str = "###\n### ''#{params[:title]}`` at '#{timestamp}'\n###\n\n"
            @tlog.posts(params[:postopts]).
              with_export(:txt, :tree => self){ |post|
              @str << "### " << post.metadata[:date].to_s << "\n"
              @str << post.to_txt << "\n"
            }
            @__result__ = @str
          end

          def to_s
            @str
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
