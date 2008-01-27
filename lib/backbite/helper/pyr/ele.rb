#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper
    
    module Builder

      module Pyr

        class Element < Delegator
          
          include Transformer

          include Outputter
          
          attr_accessor :args, :parent
          attr_reader   :name

          def build(&blk)
            @children = Pyr.build(&blk)
            self
          end
          
          # appends element
          def inner_append(*o)
            o.each do |ele|
              ele.parent = self
              children.push(ele)
            end
          end
          alias :push :inner_append
          alias :+    :inner_append
          
          # adds element to the begining
          def inner_prepend(*o)
            o.each do |ele|
              ele.parent = self
              children.unshift(ele)
            end
          end
          alias :unshift :inner_prepend

          def reset!
            @children = nil
            children
          end
          
          def replace(ele = nil, &blk)
            reset!
            if block_given?
              children.build(&blk)
            else
              if parent
                ele[ele.to_sym] = ele
              else
                ele
              end
            end
          end

          def to_sym
            @name.to_sym
          end
          
          def value=(o)
            @value = o
          end
          
          def value
            @value.to_s
          end
          
          def ==(o)
            self.name == o.to_sym
          end

          def children
            unless @children
              @children = Elements.new
              @children.parent = self
            end
            @children
          end

          def __getobj__
            children
          end
          
          def initialize(name, *args)
            @name, @args = name, *args
            @args ||= []
            @value = ''
          end
          
          def inspect
            "<Ele: #{name.to_s.upcase}:#{value.dump} #{children.inspect}>"
          end

          # returns new element
          def self.[](obj)
            Element.new(obj.to_sym)
          end
          
          # calculates the distance to the toplevel element
          def path_length
            i = 0
            if respond_to?(:parent)
              par = parent
              par = par.parent while par.respond_to?(:parent) and i+=1
            end
            i
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
