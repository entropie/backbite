#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Hg < Plugin

  def input
    "mercurial commit message"
  end

  def transform!(str)
    str
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
