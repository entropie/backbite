#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Backbite

  module Helper
    
    module Builder

      module Pyr

        module Builder
          
          attr_accessor :parent
          attr_accessor :build_block
          
          def build(&blk)
            raise "build is closed" if closed?
            @build_block = blk
            instance_eval(&blk) if block_given?
            close_clean
            self
          end

          def close_clean
            clean!
            close
          rescue
          ensure
            self
          end
          
          def clean!
            class << self
              [:p, :id, :clean!].each do |m|
                alias_method("__#{m}__", m)
                undef_method(m) rescue nil 
              end
            end
          end
          
          def close
            @closed = true
          end

          def open
            @closed = false
          end

          def closed?
            @closed or false
          end

          def method_missing(*args, &blk)
            super unless ele = __eval__(*args, &blk)
            ele
          end

          def __eval__(m, *args, &blk)
            return false if closed?
            ele = Element[m]
            if (arg = args.first and (arg.kind_of?(String) or arg.kind_of?(Symbol)))
              ele.value = args.shift
            end
            ele.args = args
            ele.parent = parent
            ele.children.extend(Builder).build(&blk)
            push(ele)
            self
          end
          private :__eval__
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
