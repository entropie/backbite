#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class Image < Plugin

  require 'RMagick', "image plugin is designed to work with RMagick"

  include Helper::CacheAble
  
  def thumbnail(img)
    Cache(img) do
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
      [ img.columns, img.rows, "#{cd}/#{b_imgname}", "#{cd}/#{t_imgname}"]
    end
  end

  def input; end

  def html_filter
    x, y, url, thumb = thumbnail(field.value)
    "<a href=\"#{url}\"><img height=\"#{y}\" width=\"#{x}\" alt=\"Source: #{field.value}\" src=\"#{thumb}\" /></a>"
  end
  alias :atom_filter :html_filter
  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
