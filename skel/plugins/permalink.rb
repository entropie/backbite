#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Permalink < Plugin

  def filter
    component.metadata[:date].strftime(Repository::Export::ARCHIVE::DateFormat)
  end

  def url(pd = 0)
    "#{tlog.url.to_s.strip}/archive/#{filter}/##{identifier}"
  end
  
  def txt_filter
    "#{filter}##{identifier}"
  end
  
  def html_filter
    '<a class="pl" href="%s%s/%s/index.html#%s">#</a>' % [path_deep, 'archive', filter, identifier]
  end

  def latex_filter
    "\\href{#{url}}-{#{identifier}}"
  end

  def atom_filter
    atom_url
  end

  def atom_url
    "<a href=\"#{url}\">#{url}</a>"
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
