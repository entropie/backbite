#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Permalink < Plugin
  def filter
    adate = component.metadata[:date].strftime(Repository::Export::ARCHIVE::DateFormat)
    '<a class="pl" href="%s%s/%s/#%s">#</a>' % [path_deep, 'archive', adate, identifier]
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
