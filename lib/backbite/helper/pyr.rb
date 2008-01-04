#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'ostruct'

module Backbite

  module Helper

    module Builder

      class Pyr

        # handles ways to fetch things
        module Accessor
          def children
            self[name].keys
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
                  ret = ret.__fetch__(node)
                end
              end
            else
              ret = ret.__fetch__(o) if o.kind_of?(Symbol)
            end
            return ret
          end
        end
        
        module Builder
          
          attr_accessor :parent
          
          def data
            @data ||= Helper::Dictionary.new
          end

          def fetch(obj)
            @data[obj.to_sym]
          end
          alias :__fetch__ :fetch
          
          def args
            @args ||= []
          end
          
          def build(&blk)
            builder = extend(Builder)
            builder.instance_eval(&blk) if block_given?
          end

          def path_length
            i = -1
            if respond_to?(:parent)
              par = parent
              while par.respond_to?(:parent)
                par = par.send(:parent)
                i+=1
              end
            end
            i
          end
          
          def method_missing(m, *args, &blk)
            unless @closed
              ele = Element[m]
              ele.extend(Builder)
              ele.parent = self
              ele.args = args
              ele.build(&blk)
              data[m] ||= Elements.new
              data[m] << ele
            else
              super
            end
            ele
          end
        end

        include Builder
        
        class Elements < Array
          
          include Accessor

          def keys
            self
          end
          alias :children :keys
          
          def method_missing(m, *args, &blk)
            if m.to_s =~/(value|path_length)/ and size == 1
              if (target = first).respond_to?(m)
                return target.send(m, *args, &blk)
              end
            else
              super
            end
          end
          
          def __fetch__(obj)
            retval = self.dup
            retval.reject! { |ele|
              ele.data[obj.to_sym].nil?
            }
            retval.map!{ |ele|
              ele.data[obj.to_sym]
            }
            retval.flatten!
            retval
          end
        end

        class Element
          
          include Accessor
          
          attr_accessor :args
          attr_reader  :name
          
          def close
            @closed = true
          end
          def closed?
            @closed
          end
          
          def value=(o)
            args.clear << o
          end
          
          def value
            @args.to_s
          end
          
          def ==(o)
            self.name == o.to_sym
          end
          
          def initialize(name)
            @name = name
          end
          
          def inspect
            "(Ele: #{name.to_s.upcase}:#{parent.name}:#{data.inspect})"
          end

          def self.[](obj)
            ele = Element.new(obj.to_sym)
            ele
          end

          def build(&blk)
            instance_eval(&blk) if block_given?
            self
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
