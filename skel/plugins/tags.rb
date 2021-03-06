#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Tags < Plugin

  def input
    'Tags:'
  end

  def transform!(inp)
    inp.to_s.scan(/(\w+),?\s?/).flatten
  end
  
  def filter
    field.value.join(', ')
  end

  def txt_filter
    field.value.join(' ')
  end

  def atom_filter
    html_filter
  end
  
  def html_filter
    fs = field.value.map{ |v|
      "<a class=\"tag\" href=\"#{path_deep}tags/#{v}.html\">#{v}</a>"
    }
    tgs = if fs.size > 1
            "#{fs[0..-2].join(', ')} and #{fs.last}"
          else
            "#{fs.join(', ')}"
          end
    "Filed in #{tgs}."
  end

  def latex_filter
    prfx, fs = "\\emph{", field.value.map{ |v|
      "\\href{#{ tlog.url.to_s.strip}/tags/#{v}.html}-{#{v}}".strip
    }
    tgs = if fs.size > 1
            "#{fs[0..-2].join(', ')} \\emph{and} #{fs.last}"
          else
            "#{fs.join(' ')}"
          end
    "Filed in #{ prfx }#{tgs.strip}.}"
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
