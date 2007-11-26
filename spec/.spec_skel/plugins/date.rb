#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Date < Plugin

  def content
    Time.now
  end

  def filter
    field.value.strftime("%Y %B, %d at %H:%M  %Z")
  end

  def html_filter
    f = []
    nbs = neighbors.each_with_index{ |po, i|
      unless po then f << ''; next end
      t = if i.zero? then 'back in time' else 'walk in time' end
      f << %(<a style="rellink" title="#{t}" href="##{po.identifier}">&nbsp;#{i == 0 ? '&lt;' : '&gt;'}&nbsp;</a>)
    }
    f.first + filter + f.last
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
