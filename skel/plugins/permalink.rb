#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Permalink < Plugin

  def filter
    component.metadata[:date].strftime(Repository::Export::ARCHIVE::DateFormat)
  end

  def txt_filter
    "#{filter}##{identifier}"
  end
  
  def html_filter
    '<a class="pl" href="%s%s/%s/index.html#%s">#</a>' % [path_deep, 'archive', filter, identifier]
  end

  def latex_filter
    "\\href{#{tlog.url.to_s.strip}/archive/#{txt_filter}}-{#{identifier}}"
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
