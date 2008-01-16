#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Toc < Plugin

  def self.mk_tagcloud_tagsize(val, tmi, tma)
    f = 2.0
    ((f* (val-tmi)) / (tma - tmi))
  end
  
  def content
    wd = tlog.repository.working_dir('archive')
    return proc{ } unless wd.exist?
    entries = wd.
      entries.grep(/^[^\.]/).map{ |ar| Time.parse(ar.to_s)}

    hk =  Hash.new{ |hash, key| hash[key] = 0 }
    
    tlog.posts do |po|
      po.tags.each { |t|
        hk[t] += 1
      }
    end
    pd = path_deep
    tcs = hk #.sort_by{ |h,k| k }.reverse
    hk = nil
    
    h = { }

    entries.each do |e|
      (h[e.strftime("%Y%m")] ||= []) << e
    end
    keys, path = h.keys.sort.reverse, tlog.http_path('archive/')
    tagpath = tlog.http_path('tags/')
    lambda do
      div(:class => 'archive node') {
        h2 "Archive"
        ul {
          keys.each { |key|
            val = h[key]
            lpath = "#{path}#{key}"
            nv = val.sort.reject{ |v| v.strftime("%Y%m") != key }
            li(:class => "head") {
              strong("#{key.gsub(/^(\d\d\d\d)/, '\1/')}")
              i(" (#{nv.size})")
            }
            li { 
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
      }
      
      div(:class => 'node tags') {
        h2 "Tags"
        ul {        
          tcs.each { |name, val|
            so = tcs.sort_by{ |a,b| b }
            mi,ma = so.first.last,so.last.last
            #$stdout.puts mi,ma
            s = Toc.mk_tagcloud_tagsize(val, mi-2, ma)+0.5
            s = s.to_s[0..3]
            li{
              a(:style => "font-size:#{s}em", :href=> "#{pd}tags/#{name}.html"){ name }
              #              i(" (#{val})")
            }
          }
        }
        p ""
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
