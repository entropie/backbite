#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::ARCHIVE

    DateFormat = '%Y%m%d'
    
    def self.export(tlog, params)
      psts = { }
      all_posts = tlog.archive + tlog.posts
      all_posts.each do |post|
        y,m,d = post.metadata[:date].strftime(tlog.config[:defaults][:archive_date_format]).split('/')
        [y, "#{y}/#{m}"].each do |sd|
          date,matcher =
            begin
              [Date.parse(sd), lambda{|a| a.metadata[:date].year == date.year and a.metadata[:date].month == date.month }]
            rescue
              [Date.new(sd.to_i), lambda{|a| a.metadata[:date].year == date.year }]
            end
          psts[sd] ||= []
          all_posts.select(&matcher).each do |npost|
            psts[sd] << npost.pid
          end
          psts[sd].uniq!
        end
        
        fname = post.metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
        (psts[fname] ||= []) << post.pid
      end
      archive_dir = tlog.repository.working_dir('archive')
      result = ''

      psts.each_pair do |d, pids|
        FileUtils.mkdir_p(archive_dir.join(d))

        file = archive_dir.join(d, 'index.html')
        tree = Tree.new(d, file, tlog.dup, params)
        Debug << "ARCHIVE: #{d} pids=#{pids.join(',')}"
        tree.export_date(*pids)
        result << tree.write
      end
      result
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
        af = @file.to_s.gsub(tlog.repository.working_dir.to_s+'/', '')
        pd = af.split('/').size-1
        h = {
          :title => "Archive: @#{@date}",
          :ids => pids,
          :nowrite => true,
          :path_deep => '../' * pd,
          :nolimit => true,
          :archive => true
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
