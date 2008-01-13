#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'ostruct'

module Backbite

  module Helper

    module Builder
      # :include:../../../doc/pyr.rdoc
      class Pyr

        attr_reader :indent
        def initialize
          @indent = 0
        end

        def self.build(ind = 0, &blk)
          new.build(ind, &blk)
        end

        def indent=(o)
          @indent = o
        end

        module Outputter
          
          ELEMENTS = {
            :blocklevel => %w(ul p table div body html head),
            :inline     => %w(a title li span bold i accronym strong img link meta h1 h2 h3 h4 h5 h6 script)
          }

          def Outputter.fmt_args(args, ind = 0)
            return '' unless args
            rh = { }
            args.each do |arg|
              case arg
              when String
              when Pyr, Element, Elements
              when Array
                if arg.all?{ |a| a.kind_of?(Element) }
                  arg.map!{ |a| a.indent = ind }
                end
              else
                rh.merge!(arg)
              end
            end
            args = rh.map{ |a,b| "#{a}=\"#{b}\""}.join(' ')
            args.empty? ? '' : " "+args
          end

          def Outputter.inline_element?(ele)
            case ele.to_s
            when *ELEMENTS[:inline]
              true
            when *ELEMENTS[:blocklevel]
              false
            end
          end
          
          def __prefix__(first = false)
            if respond_to?(:name) and Outputter.inline_element?(name)
              return '' unless first
            end
            "\n#{"  "*indent}"
          end
          

          def to_html
            childs, ret = children, ''
            case self
            when Elements
            when Element
              nargs = Outputter.fmt_args(args, @indent+1)
              ret << "" << __prefix__(true) << "<#{self.name}#{nargs}>"
              ret << value
            end
            
            childs.each do |mab, ele|
              t = if mab.kind_of?(Symbol) then ele else mab end
              ret << t.to_html
            end if childs

            ret << "#{__prefix__}</#{self.name}>" if self.kind_of?(Element)
            ret
          end
          alias :to_s :to_html
        end
        
        module Transformer

          def inner_append(ind = 0, &blk)
            ret = Pyr.build(last.path_length + ind, &blk)
            last.data.push(ret.name, ret)
            self
          end

          def inner_prepend(ind = 0, &blk)
            ret = Pyr.build(first.path_length + ind, &blk)
            first.data.push(ret.name, ret)
            self
          end

          def append(ind = 0, &blk)
            __set__(:push, ind, &blk)
          end

          def prepend(ind = 0, &blk)
            __set__(:unshift, ind, &blk)
          end

          def __set__(where, ind = 0, &blk)
            pl = respond_to?(:path_length) ? path_length : 0
            ret = Pyr.build(pl + ind, &blk)
            send(where, ret)
            self
          end

          private :__set__
        end
        
        module Accessor
          
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
        
        module Builder
          
          attr_accessor :parent

          def build(ind = 0, &blk)
            builder = extend(Builder)
            builder.indent = ind
            builder.instance_eval(&blk) if block_given?
          end


          def data(reset = false)
            @data = nil if reset
            @data ||= Helper::Dictionary.new
          end
          alias :children :data
          
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

          def closed?
            @closed or false
          end

          def __append_node__(m, *args, &blk)
            unless closed?
              ele = Element[m]
              if (arg = args.first and (arg.kind_of?(String) or arg.kind_of?(Symbol)))
                ele.value = args.shift
              end
              ele.parent, ele.args = self, args
              ele.build(&blk)
              data[m] ||= Elements.new
              data[m].parent = self
              data[m].indent = respond_to?(:path_length) ? path_length : @indent
              #data[m].indent = path_length
              data[m] << ele
              ele
            else
              false
            end
          end
          
          def method_missing(*args, &blk)
            super unless ele = __append_node__(*args, &blk)
            ele
          end
        end

        include Builder

        class Elements < Array
          
          include Accessor
          include Outputter
          #include Builder

          attr_accessor :indent
          attr_accessor :parent
          
          def <<(o)
            o.indent = @indent
            super
          end
          
          def keys
            self
          end

          alias :children :keys

          def fetch(obj)
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

          def method_missing(m, *args, &blk)
            if m.to_s =~/(value|path_length)/ and size == 1
              if (target = first).respond_to?(m)
                return target.send(m, *args, &blk)
              end
            else
              super
            end
          end

        end

        class Element
          
          include Accessor
          include Transformer
          include Outputter
          
          attr_accessor :args
          attr_accessor :indent
          attr_reader  :name

          def unshift(o)
            data.unshift(o.name, o)
          end

          def push(o)
            data.push(o.name, o)
          end

          def reset!
            data(true)
          end
          
          def replace(ele = nil, &blk)
            reset!
            if block_given?
              instance_eval(&blk)
            else
              @data[ele.name] = ele
            end
            self
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

          def initialize(name)
            @name = name
            @value = ''
          end
          
          def inspect
            par = parent.respond_to?(:name) ? parent.name : ':'
            "\n#{"  "*path_length}(Ele: #{name.to_s.upcase}:#{data.inspect})[\"#{value}\"]"
          end

          def self.[](obj)
            ele = Element.new(obj.to_sym)
            ele.extend(Builder)
            ele.clean!
            ele
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
