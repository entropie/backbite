#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Symbol
  def to_proc
    lambda{|o, *args| o.send(self, *args) }
  end

  def <=>(o)
    self.to_s <=> o.to_s
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
