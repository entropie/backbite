#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  class Archive < Posts

    def self.archive_post(tlog, post)
      adir = tlog.repository.
        archive_dir(post.date.year, "%02i" % post.date.month)
      fname = "#{"%02i" % post.date.day}-#{post.file.basename}"
      tdir = adir.join(fname)
      Backbite.wo_debug{ FileUtils.mkdir_p(adir) }
      Info << "archiving #{post.identifier} to #{tdir.to_s.split('/')[-4..-1].join('/')}"
      post.file.rename(tdir)
    end
    
    def initialize(tlog)
      super(tlog)
      @archive = @tlog.repository.archive_dir
    end
    
    def days(year = nil, month = nil)
      months(year).map do |amonth|
        if month
          next if month.to_s.to_i != amonth.to_s.split('/').last.to_i
        end
        
        @tlog.root.join(amonth).entries.grep(/^[^\.]+/).map{ |file|
          @tlog.root.join(amonth, file)
        }
      end.compact.flatten.sort
    end
    
    def months(year = nil)
      ret = []
      ys = years
      ys.reject!{ |y| y.to_s != year.to_s } if year
      ys.each do |year|
        yeardir = Pathname.new('archive').join(year)
        @archive.join(year).entries.grep(/^[^\.]+/).each do |month|
          ret << yeardir.join(month)
        end
      end
      ret.sort
    end
    
    def years
      @archive.entries.grep(/^[^\.]+/).map{ |entry| entry.to_s }.sort
    end
    
    def read
      months.each do |monthdir|
        super(monthdir)
      end
      self
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
