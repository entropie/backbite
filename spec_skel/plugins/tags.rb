#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Tags < Plugin

  def input
    'Tags:'
  end

  def transform(inp)
    inp.to_s.scan(/(\w+),?\s?/).flatten
  end
  
  # def content
  #   []
  # end

  def filter        #  - filter applied for every output module
    field.value.join(', ')
  end

  def txt_filter   # - specific filter for output module
    p tree.class
    p field.class
    p component.class
    p tlog.class
    field.value.join(' ')
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
