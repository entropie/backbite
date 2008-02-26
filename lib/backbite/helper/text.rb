#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


Backbite.wo_debug do
  begin
    require 'text/format'
  rescue LoadError
    warn $! if $DEBUG
    module Backbite::Helper::Text
      def paragraphify(text, prfx)
        text
      end
    end
  else
    module Backbite
      module Helper
        module Text
          def paragraphify(text, prfx = 16)
            ::Text::Format.new.format(text)[0..-2].split("\n").
              join("\n"+(" "*prfx))
          end
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
