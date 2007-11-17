#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Date < Plugin

  def content
    Time.now
  end

  def filter                    # filter applied for every output module
    field.value.strftime("%Y %B, %M at %H:%M  %Z")
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
