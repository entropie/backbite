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
      tag_dir = tlog.repository.working_dir('tags')
      tag_dir.mkdir unless tag_dir.exist?
      all = []
      tags = params[:tags]
      if tags
        all = tags
      else
        tags = (tlog.posts + tlog.archive).map{ |post|
          [post.pid, post.tags]
        }.inject(all) { |m, t|
          m << t.last
        }
        all = all.flatten.uniq
      end
      result = ''
      all = all.flatten.sort
      s = all.size.to_s.size
      all.sort!.each_with_index do |t, i|

        Info << "[%#{s}i/%i] #{t.green}" % [i, all.size]
        filename = tag_dir.join("#{sanitize_tag(t)}.html")
        tree = Tree.new(t, filename, tlog, params)
        tree.export_tag
        tree.write
        tree = nil
      end
    end
    
    class Tree < Repository::ExportTree # :nodoc: All

      attr_reader :result, :tag

      def initialize(tag, filename, tlog, params)
        super(tlog, params)
        @file = filename
        @tag = tag
      end

      def to_s
        @result
      end
      
      def export_tag
        phash = {
          :title => "Tag: #{@tag}",
          :tags => [@tag], :norenumber => true,
          :nowrite => true,
          :path_deep => '../',
          :nolimit => true,
          :archive => true
        }
        @result = tlog.repository.export(:html, phash).to_s
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
