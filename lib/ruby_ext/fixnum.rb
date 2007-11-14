#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Fixnum
  def method_missing(m, *a, &blk)
    if m.to_s =~ /^(em|px)$/
      return "#{self}#{m}"
    elsif m.to_s =~ /days/
      self*24*60*60
    else
      super
    end
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
