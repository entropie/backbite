#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::ARCHIVE

    DateFormat = '%Y%m%d'

    def self.date(o)
      if o.include?('/')
        Date.new(*o.split('/').map{ |i| i.to_i})
      else
        Date.new(o.to_i)
      end
    end
    
    def self.export(tlog, params)
      psts = { }
      what = params[:date]
      all_posts = tlog.archive
      j = 0
      all_posts.each do |post|
        y,m,d = (dd=post.metadata[:date].strftime(tlog.config[:defaults][:archive_date_format]).split('/'))
        [y, "#{y}/#{m}"].each do |sd|
          date = self.date(sd)
          psts[date] ||= []
          psts[date] << post.pid if post.date.year == date.year
          psts[date].uniq!
        end
        
        fname = dd
        (psts[[y,m,d]] ||= []) << post.pid
      end

      archive_dir = tlog.repository.working_dir('archive')
      result = ''

      psts.each_pair do |d, pids|
        next if what and what != d
        d = d.to_s.split('-') if d.kind_of?(Date)
        FileUtils.mkdir_p(archive_dir.join(*d))

        file = archive_dir.join(*d).join('index.html')
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
