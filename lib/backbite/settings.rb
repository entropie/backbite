#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # A dummy which returns a Configurations instance with the name set.
  class Config


    def self.[](obj)
      Configuration.new(obj.to_sym)
    end
    

    def self.read(data)
      Configuration.read(data)
    end


    module Replacer
      
      attr_reader :root

      def root=(obj)
        @root = obj
        self
      end


      # Walks the entire hash and substitutes every %replace_thing%
      # for our values. It needs the toplevel element, <tt>:defaults</tt> to
      # get the values to replace from <tt>config[:defaults][:replace]</tt>
      def replace!
        rpo = @root[:defaults][:replace]
        rpfr = rpo.keys.map{ |k| "%#{k.to_s}%"}
        ret = self
        each do |a, b|
          if b.kind_of?(Hash)
            rp = b.extend(Replacer)
            rp.root = @root
            ret[a] = rp.replace!
          else
            ret[a] = b = b.call if b.kind_of?(Proc)
            vlrg = Regexp.new("(#{rpfr.join('|')})")
            while vlrg =~ b.to_s and str = $1 and !str.empty?
              value = rpo[str.gsub(/%/, '').to_sym].to_s
              ret[a].gsub!(/#{str}/, value)
              b = ret[a]
            end
          end
        end
        ret
      end
      
    end

    
    module Parser

      
      # extends current instance with ConfigReplacer, starts the replace
      # loop and after work is done it removes the
      # config[:defaults][replace] pairs, because they're not longer needed.
      def with_replacer
        ret = extend(Replacer)
        ret.root = self
        ret.replace!
        ret[:defaults].delete(:replace)
        ret
      end
      
      def cleanup
        class << self
          [:replace, :id, :clear].each do |m|
            self.send(:undef_method, m)
          end
        end
        self
      end


      def read(&blk)
        instance_eval(&blk)
        self
      end


      # Returns an array containing the keys of the current Hash in the
      # order of inserting.
      def order
        @order ||= []
      end
      

      # Returns an Array of nodes, ordered, first element is the name of
      # the node, second the ordered values array.
      def sort
        ret = []
        order.each do |o|
          t = if self[o].kind_of?(Hash) then self[o].ordered else self[o] end
          ret << [o,t]
        end
        ret
      end
      

      def method_missing(m, v = Parser.config_hash, &b)
        m = m.to_s.gsub(/=$/, '').to_sym
        unless self.keys.include?(m)
          order << m
          self[m] = v
        end
        self[m].read(&b) if block_given? #and self[m].respond_to?(:read)
        self[m]
      end


      def self.config_hash
        Hash.new{ |h,k| h[k] = config_hash }.extend(Parser).cleanup
      end
    end


    class Configuration
      
      attr_reader :config

      def keys
        @config.keys
      end
      
      def self.read(str)
        path = Pathname.new(str)
        if path.exist?
          str = path.readlines.join
        end
        instance_eval(str)
      end
      

      def initialize(name)
        @name = name
        @config = Parser.config_hash
      end


      # Call this to setup your repository.
      def setup(&blk)
        @config.read(&blk)
        @config
      end


      def [](obj)
        each do |n, v|
          next unless obj == n
          return v
        end
      end
      

      def []=(obj, val)
        each do |n, v|
          next unless obj == n
          @config[obj] = val
        end
      end
      

      def each(&blk)
        @config.each(&blk)
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