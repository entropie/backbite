#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Author < Plugin          

  def make_mailto(author_str)
    # "Michael Trommer <mictro@gmail.com>"
    author_str.gsub(/<(.*)>/, '&lt;<a class="author" href="mailto:\1">\1</a>&gt;')
  end
  
  def input
  end

  def html_filter
    field.value = tlog.author if field.value.to_s.empty?
    "by <strong>#{make_mailto(field.value.to_s)}</strong>"
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
