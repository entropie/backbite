#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  module Helper

    module FUtils

      def mkdir_p(*args)
        args.map!(&:to_s)
        Info << "making directories #{args.join('/')}"
        FileUtils.mkdir_p(*args)
      end

      module_function :mkdir_p
      
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
