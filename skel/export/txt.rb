#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Post
    # Export contains a list of Modules to extend the Post class. E.g.
    # to use the +:html+ way to export the Repository, you first need
    # to define a Repository::Export sublcass, named HTML, which
    # responds to :export, therein your ExportTree will be evaluated
    # and uses via +with_export+ the +to_foo+ method of the extend
    # Post instance.
    # 
    # Got it? nope? see lib/export/*.rb for examples.
    class Export

      module TXT

        include Helper::Text        

        def to_txt
          str = "#{metadata[:component].to_s.capitalize} {"
          fields.each do |field|
            f, filtered = field.to_sym, field.apply_filter(:txt)
            filtered = paragraphify(filtered.to_s)
            str << "\n %-10s %s" % [f.to_s+':', filtered]
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
            from = tlog.author
            @str = "#\n# Title: #{params[:title]}\n# Generated at: #{timestamp}\n# By: #{from}\n#\n# URL: #{tlog.http_path}\n#\n\n"
            tlog.posts.by_date!.reverse.each do |post|
              post = post.with_export(:txt, params.merge(:tree => self))
              @str << post.to_txt
            end
            @str
          end

          def to_s
            @str.to_s
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
