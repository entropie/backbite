#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::ARCHIVE

    DateFormat = '%Y%m%d'
    
    def self.export(tlog, params)
      archive = tlog.archive
      archive.years.each do |year|
        p year
      end
      ''
      # all_posts = tlog.posts
      # ds = { }
      # all_posts.each do |post|
      #   filename = post.metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
      #   (ds[filename] ||= []) << post
      # end
      # archive_dir = tlog.repository.working_dir('archive')
      # archive_dir.mkdir unless archive_dir.exist?
      # result = ''

      # ds.each_pair do |d, posts|
      #   pids = posts.map{ |pos| pos.pid }
      #   tree = Tree.new(d, archive_dir.join(fn="#{d}/index.html"), tlog.dup, params)
      #   Debug << "ARCHIVE: #{fn} pids=#{pids.join(',')}"
      #   tree.export_date(*pids)
      #   result << tree.write
      # end
      # result
    end

    class Tree < Repository::ExportTree # :nodoc: All

      def initialize(date, filename, tlog, params)
        super(tlog, params)
        @date = date
        @file = filename
      end

      def to_s
        @result
      end
      
      def export_date(*pids)
        h = {
          :title => "Archive: @#{@date}",
          :ids => pids,
          :nowrite => true,
          :path_deep => '../../'
        }
        @result = tlog.repository.export(:html, h).to_s
        self
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
