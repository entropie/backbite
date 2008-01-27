#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper
    
    module Builder

      module Pyr

        class Elements < Array
          
          include Outputter
          attr_accessor :parent

          def include?(o)
            o = o.to_sym
            any?{ |ele| ele == o } and return true
            false
          end

          def remove(o)
            raise "need kind of Element" unless o.kind_of?(Element)
            include?(o.name) and delete(o)
          end
          
          def [](o)
            ret =
              case o
              when Symbol, String
                include?(o) and select{ |ele| ele == o }
              when Element
                return self[o.to_sym]
              when Fixnum
                return super(o)
              end
            return nil unless ret
            return ret.size == 1 ? ret.first : ret
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
