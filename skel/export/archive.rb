#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::ARCHIVE

    include Backbite::Helper

    def self.mkdate(time, tlog)
      time.strftime(tlog.config[:defaults][:archive_date_format]).to_s
    end
    
    def self.format_date_params(what, tlog)
      what =
        case what
        when nil
          []
        when Time
          [what]
        when Array
          what
        else
          Error << "dunnow howto handle: #{what.class}:#{what}"
        end
      what.map{ |d|
        mkdate(d, tlog)
      }.uniq
    end
    
    def self.export(tlog, params)
      psts = { }
      what = format_date_params(params[:date], tlog)
      all_posts = tlog.archive + tlog.posts
      result = ''
      pref_dates = params[:date]
      all_posts.each do |post|
        date = post.metadata[:date]
        next if pref_dates and not [pref_dates].flatten.include?(date)
        datestr = mkdate(date, tlog)
        datestr.split('/').inject([]) do |m, ds|
          m << ds
          psts[nds=m.join('/')] ||= []
          all_posts.select{ |pst| mkdate(pst.date, tlog) == datestr }.each do |npst|
            psts[nds] << npst.pid
          end
          m
        end
        psts[datestr] ||= []
        next if not what.empty? and post.archived?
        psts[datestr] << post.pid 
      end
      archive_dir = tlog.repository.working_dir('archive')
      s, i = what.size.to_s.size, 0

      psts.sort_by{ |d,ps| d}.each do |d, pids|
        #next if not what.empty? and not what.include?(d)
        dates = d.to_s.split('/')
        FUtils.mkdir_p(ad = archive_dir.join(*dates))
        file = ad.join('index.html')
        Info << "[%#{s}i/%i] #{d.green}" % [i+=1, psts.size]
        Debug << "ARCHIVE: #{file} pids=#{pids.join(',')}"
        tree = Tree.new(d, file, tlog.dup, params)
        tree.export_date(*pids)
        result << tree.write
      end
      result
    end

    class Tree < Repository::ExportTree

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
