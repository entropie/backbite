#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper
    
    module Builder

      module Pyr
        module Accessor # :nodoc: All
          
          def children
            data
          end
          
          def keys
            data.keys
          end

          def [](o)
            ret = self
            obj = o.to_s
            case obj
            when /\//
              nodes = obj.split('/').reject{ |e| e.empty? }
              while node = nodes.shift
                case node
                when '.'
                when '..'
                  if ret.size == 1
                    ret = ret.first.parent
                  else
                    raise "multible parent choices are forbidden"
                  end
                else
                  ret = ret.fetch(node)
                end
              end
            else
              ret = ret.fetch(o) if o.kind_of?(Symbol)
            end
            tret = ret.extend(Transformer)
            return tret
          end

          def fetch(obj)
            @data[obj.to_sym]
          end

          def args
            @args ||= []
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
