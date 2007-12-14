#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::TAGS

    def self.sanitize_tag(tag)
      tag
    end
    
    def self.export(tlog, params)
      all = []
      tags = tlog.posts.map{ |post|
        [post.pid, post.tags]
      }.inject(all) { |m, t|
        m << t.last
      }
      all = all.flatten.uniq

      tag_dir = tlog.repository.working_dir('tags')
      tag_dir.mkdir unless tag_dir.exist?
      result = ''
      all.each do |t|
        filename = tag_dir.join("#{sanitize_tag(t)}.html")
        tree = Tree.new(t, filename, tlog, params)
        tree.export_tag
        result << tree.write
      end
      result
    end
    
    class Tree < Repository::ExportTree # :nodoc: All

      attr_reader :result, :tag

      def initialize(tag, filename, tlog, params)
        super(tlog, params)
        @file = filename
        @tag = tag
      end

      def export_tag
        phash = {
          :title => "Tag: #{@tag}",
          :postopts => { :tags => [@tag], :norenumber => true},
          :nowrite => true,
          :path_deep => '../'
        }
        @__result__ = tlog.repository.export(:html, phash).to_s
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
