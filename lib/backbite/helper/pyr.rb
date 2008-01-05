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

        module Outputter
          
          def fmt_args(args)
            return ['', ''] unless args
            rh = { }
            args.each do |arg|
              case arg
              when String
              else
                #pp arg
                rh.merge!(arg)
              end
            end
            args = rh.map{ |a,b| "#{a}=\"#{b}\""}.join(' ')
            args.empty? ? '' : " "+args
          end

          def prefix
            "#{"  "*(path_length)}"
          end
          
          def to_tag
            childs, ret = nil, ''
            prfx = ''
            case self
            when Element
              nargs = fmt_args(args)
              ret << "\n" << prefix << "<#{self.name}#{nargs}>"
              ret << value
              childs = children
            when Elements
              childs = children
            end
            childs.each do |mab, ele|
              t = if mab.kind_of?(Symbol) then ele else mab end
              ret << t.to_tag
            end if childs
            ret << "</#{self.name}>\n" if self.kind_of?(Element)
            ret
          end
          
          def to_html            
            to_tag
            #parent.data.first.to_tag
          end
          
          def to_s
            case self
            when Elements
              to_tag
            when Element
              to_html
            else
            end
          end
        end
        
        module Transformer
          
          def append(&blk)
            set(:push, &blk)
          end

          def prepend(&blk)
            set(:unshift, &blk)
          end

          def set(where, &blk)
            ret = Pyr.new.build(&blk)
            case self
            when Elements
              send(where, ret)
            when Element
              send(where, ret)
              self
            end
          end
        end
        
        # handles ways to fetch things
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

          def data(reset = false)
            @data = nil if reset
            @data ||= Helper::Dictionary.new
          end
          alias :children :data
          
          def build(&blk)
            builder = extend(Builder)
            builder.instance_eval(&blk) if block_given?
          end

          def clean!
            class << self
              [:p, :id, :clear].each do |m|
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
          
          def method_missing(m, *args, &blk)
            unless closed?
              ele = Element[m]
              if args.first.kind_of?(String)
                ele.value = args.shift
              end
              ele.parent, ele.args = self, args
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
          include Outputter

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

          def build(&blk)
            instance_eval(&blk) if block_given?
            self
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
