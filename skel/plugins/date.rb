#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Date < Plugin

  def metadata_inject
    :date
  end

  def content
    Time.now
  end

  def filter
    field.value.strftime("%Y %B, %d - %H:%M  %Z")
  end

  def html_filter
    f = []
    nbs = neighbors.each_with_index{ |po, i|
      unless po then f << ''; next end
      t = if i.zero? then 'previous entry' else 'next entry' end
      f << %(<a style="rellink" title="#{t}" href="##{po.identifier}">&nbsp;#{i == 0 ? '&lt;' : '&gt;'}&nbsp;</a>)
    }
    #f.first + filter + f.last
    filter.gsub(/\-/, '&mdash;')
  end

  def latex_filter
    field.value.strftime("%Y %B, %A %d   %H:%M  %Z")
  end

  def to_atom_id
    field.value.strftime("%a, %d %b %Y %H:%S +0000")
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
