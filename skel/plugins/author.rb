#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Author < Plugin          
 
  def input
  end

  def html_filter
    CGI.escapeHTML(field.value.to_s)
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
