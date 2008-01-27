#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'ostruct'

%w'tidy outp transf build accs eles ele'.each do |l|
  require "lib/backbite/helper/pyr/#{l}"
end

module Backbite

  module Helper
    
    module Builder
      
      # :include:../../../doc/pyr.rdoc
      module Pyr

        attr_accessor :build_block

        def self.build(&blk)
          pyr = Pyr::Elements.new.extend(Builder).build(&blk)
          pyr.close_clean
          pyr
        end

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
