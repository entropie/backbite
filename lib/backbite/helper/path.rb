#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  module Helper
    class File
      def self.ep(file)
        Pathname.new(::File.expand_path(file))
      end
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
