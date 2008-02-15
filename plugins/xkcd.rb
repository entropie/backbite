#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'pathname'
require 'pp'
require 'pstore'
require 'open-uri'
require 'uri'
require 'hpricot'

class XKCD < Plugin

  include Helper::Image
  
  URL =       'http://xkcd.com/%s/index.html/'

  def hpricot
    @hpricot = Hpricot.parse(open(URL % ''))
  end
  
  def get_ids
    cid = hpricot.search("div.menuCont").search("a[@accesskey=p]").attr(:href)[1..-2].to_i
    [cid-1, cid, cid+1]
  end

  def images_by_ids(*ids)
    ids.map do |i|
      Hpricot.parse(open(URL % i.to_s)).search('h3').map{ |e| e.inner_text }
    end.map{ |perm, img| [URI.extract(perm).last, URI.extract(img)].flatten }
  end
  
  def read
    images_by_ids(*get_ids)
  end

  def content
    t = self
    Pyr.build{
      t.read.each do |perm, url|
        ul{ 
          li{
            a(:href => perm) {
              x, y, url, thumb = t.thumbnail_and_safe(url, '460x300')
              img(:src => thumb, :width => x, :height => y, :alt => "xkcd")
            }
          }
        }
      end
      div :style => "clear:left"
    }
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
