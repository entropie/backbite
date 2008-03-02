#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define_filter(:img) { |str|
  x, y, url, thumb = thumbnail_and_safe(str)
  %Q'<a href="#{ path_deep }#{url}"><img height="#{y}" width="#{x}" src="#{thumb}" /></a>'
}

define_filter(:tag){ |str|
  %Q'<a class="tag" href="#{ path_deep }tags/#{str}.html">#{str}</a>'
}


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
