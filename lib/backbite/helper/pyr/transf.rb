#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Backbite

  module Helper
    
    module Builder

      module Pyr

        module Transformer # :nodoc: All

          def inner_append(&blk)
            ret = Pyr.build(&blk)
            last.data.push(ret.name, ret)
            self
          end

          def inner_prepend(&blk)
            ret = Pyr.build(&blk)
            first.data.push(ret.name, ret)
            self
          end

          def append(&blk)
            __set__(:push, &blk)
          end

          def prepend(&blk)
            __set__(:unshift, &blk)
          end

          def __set__(where, &blk)
            send(where, Pyr.build(&blk))
            self
          end

          private :__set__
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
