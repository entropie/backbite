#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Toc < Plugin

  def self.mk_tagcloud_tagsize(i, tmi, tma)
    f = 2.0
    ((f* (i-tmi)) / (tma - tmi))
  end
  
  def content
    archive, tags = tlog.archive, Backbite::Posts.tags(tlog)
    pd = path_deep
    all = tlog.posts + tlog.archive
    is = tags.map{ |k,v| v}
    t = tlog
    Pyr.build do
      div(:class => 'node archive') {
        h2 "Archive"
        ul {
          archive.years.reverse.each do |year|
            li(year, :class => :head)
            li {
              ul {
                archive.months(year).each do |month|
                  li(month.to_s.split('/').last, :class => 'month')
                  li{
                    ul{
                      archive.days(year, month).map{ |p|
                        Backbite::Post.read(t, p).date.strftime('%Y%m%d')
                      }.uniq.each do |ad|
                        li{
                          a(ad[-2..-1],
                            :href => "#{pd}archive/#{ad}/index.html")
                        }
                      end
                    }
                  }
                end
              }
            }
          end
        }
      }
      
      div(:class => 'node ttags') {
        h2 "Tags"
        ul {
          tags.each_pair do |name, o|
            s = Toc.mk_tagcloud_tagsize(o, is.min-2, is.max)+0.5
            li{
              a(name,
                :style => "font-size:#{s.to_s[0..3]}em",
                :href=> "#{pd}tags/#{name}.html")
            }
          end
        }
      }
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
