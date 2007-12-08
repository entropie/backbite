#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  def Backbite::NastyDream(what)
    Class.new(GetReal)
  end

  class GetReal < Exception

    def inspect
      res = "[#{"Wake up".underline}:#{self.class.to_s.split('::').last(2).join('::').red}] #{message.to_s.white}"
      res << "\n        " << backtrace.join("\n        ") if $DEBUG
      res
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
