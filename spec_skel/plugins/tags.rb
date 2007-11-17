#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Tags < Plugin

  def input                      # undocumented
    'Tags:'
  end

  def transform!(inp)            # *really* modifies the input
    inp.to_s.scan(/(\w+),?\s?/).flatten
  end
  
  def filter                     # filter applied for every output module
    field.value.join(', ')
  end

  def txt_filter                  # specific filter for output module
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
