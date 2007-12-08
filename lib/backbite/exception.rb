#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  def Backbite::NastyDream(what)
    Class.new(GetReal)
  end

  class GetReal < Exception
    attr_accessor :from

    def backtrace
      Warn << "[Wake up: #{self.class.to_s.split('::').last(2).join('::')}] #{message}"
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
