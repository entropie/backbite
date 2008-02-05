#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  module Helper

    module Image

      include Helper::CacheAble

      require 'RMagick'
      
      def thumbnail_and_safe(img)
        Cache(img) do
          begin
            url = img
            x,y = (bimg = Magick::Image::read(img).first).columns, bimg.rows
            bimg.dup.write(cache_dir.join(b_imgname = File.basename(URI.parse(url).path)))
            img =
              if x > 320 or y > 400
                bimg.change_geometry!('320x240') { |cols, rows, img|
                bimg.resize!(cols, rows)
              }
              else
                bimg.dup
              end
            cd = "cache/#{pid}"
            thumbnail = cache_dir.join(t_imgname = "thumb_"+File.basename(URI.parse(url).path))
            img.dup.frame(5,5,5,5,2,2).write(thumbnail)
            Info << "wrote #{b_imgname} in #{cache_dir} with thumbnail"
            [ img.columns, img.rows, "#{path_deep}#{cd}/#{b_imgname}", "#{path_deep}#{cd}/#{t_imgname}"]
          rescue Magick::ImageMagickError
            ['', '', '', '']
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
