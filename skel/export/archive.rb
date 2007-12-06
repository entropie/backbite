#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::ARCHIVE

    DateFormat = '%Y%m%d'
    
    def self.export(tlog, params)
      all_posts = tlog.posts
      ds = { }
      all_posts.each do |post|
        filename = post.metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
        (ds[filename] ||= []) << post
      end

      archive_dir = tlog.repository.working_dir('archive')
      archive_dir.mkdir unless archive_dir.exist?
      result = ''
      ds.each_pair do |d, post|
        tree = Tree.new(d, archive_dir.join("#{d}/index.html"), tlog, post)
        pids = post.map{ |pos| pos.pid }
        tree.export_date(pids)
        result << tree.write
      end
      result
    end

    # Tree makes the basic (and valid) HTML frame and handles
    # the hpricot access.
    class Tree < Repository::ExportTree # :nodoc: All

      def initialize(date, filename, tlog, params)
        super(tlog, params)
        @date = date
        @file = filename
        @result = ''
      end

      def export_date(ids)
        @__result__ = tlog.
          repository.export(:html,
                            :title => "Archive: @#{@date}",
                            :postopts => { :ids => ids },
                            :nowrite => true,
                            :path_deep => '../../').to_s
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
