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
    filter
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
