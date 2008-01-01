#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Toc < Plugin

  def self.mk_tagcloud_tag(val, tmi, tma)
    f = 1.5
    ((f* (val-tmi)) / (tma - tmi))
  end
  
  include Helper::Builder
  #ID = :toc  # optional
  
  def content
    entries = tlog.repository.working_dir('archive').
      entries.grep(/^[^\.]/).map{ |ar| Time.parse(ar.to_s)}

    hk =  Hash.new{ |hash, key| hash[key] = 0 }
    
    tlog.posts do |po|
      po.tags.each { |t|
        hk[t] += 1
      }
    end
    tcs = hk #.sort_by{ |h,k| k }.reverse
    hk = nil
    
    h = { }

    entries.each do |e|
      (h[e.strftime("%Y%m")] ||= []) << e
    end
    keys, path = h.keys.sort.reverse, tlog.http_path('archive/')
    tagpath = tlog.http_path('tags/')
    str = Gestalt.build do
      h2 "Archive"
      div(:class => 'archive node') { 
        ul {
          keys.each { |key|
            val = h[key]
            lpath = "#{path}#{key}"
            nv = val.sort.reject{ |v| v.strftime("%Y%m") != key }
            li {
              strong("#{key.gsub(/^(\d\d\d\d)/, '\1/')}")
              i(" (#{nv.size})")
            }
            ul {
              nv.each{ |v|
                li{
                  a(:href=> "#{path}#{v.strftime('%Y%m%d')}/index.html") {
                    v.strftime('%d')
                  }
                }
              }
            }
          }
        }
      }
      h2 "Tags"
      
      div(:class => 'node tags') {
        p {
          ul {        
            tcs.each { |name, val|
              so = tcs.sort_by{ |a,b| b }
              mi,ma = so.first.last,so.last.last
              s = Toc.mk_tagcloud_tag(val, mi, ma)+0.7
              s = s.to_s[0..3]
              li{
                a(:style => "font-size:#{s}em", :href=> "#{tagpath}#{name}/index.html"){ name }
                #              i(" (#{val})")
              }
            }
          }
        }
      }
      
    end
    str
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
