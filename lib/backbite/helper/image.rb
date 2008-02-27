#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

Backbite.wo_debug do
  begin
    require 'RMagick'
  rescue LoadError

    warn $! if $DEBUG
    module Backbite::Helper::Image
    end

  else
    module Backbite
      module Helper

        module Image

          include Helper::CacheAble

          

          def spath=(o)
            @spath = o
          end
          
          def spath
            @spath ||= 'cache'
          end
          
          def thumbnail_and_safe(img, geo = '320x240')

            result =
              Cache(img) {
              begin
                url = img
                x,y = (bimg = Magick::Image::read(img).first).columns, bimg.rows
                bimg.dup.write(cache_dir.join(b_imgname = File.basename(URI.parse(url).path)))
                img =
                  if x > 320 or y > 400
                    bimg.change_geometry!(geo) { |cols, rows, img|
                    bimg.resize!(cols, rows)
                  }
                  else
                    bimg.dup
                  end
                cd = "cache/#{pid}"
                thumbnail = cache_dir.join(t_imgname = "thumb_"+File.basename(URI.parse(url).path))
                img.dup.frame(5,5,5,5,2,2).write(thumbnail)
                Info << "wrote #{b_imgname} in #{cache_dir} with thumbnail"
                #[ img.columns, img.rows, "#{path_deep}#{cd}/#{b_imgname}", "#{path_deep}#{cd}/#{t_imgname}"]
                [ img.columns, img.rows, "#{cd}/#{b_imgname}", "#{cd}/#{t_imgname}"]
              rescue Magick::ImageMagickError
                Warn << "no response from read in '#{pid}' -- '#{identifier}'"
                return ['', '', '', '']
              end
            }
            result = result[0..1] + result[-2..-1].map!{ |r| (path_deep||'') + r}
            result
          end
        end
        
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
