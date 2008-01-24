#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # A dummy which returns a Configurations instance with the name set.
  module Settings


    def self.[](obj)
      Configuration.new(obj.to_sym)
    end
    

    def self.read(data)
      Configuration.read(data)
    end


    def self.load(name, &blk)
      Configuration.new(name).setup(&blk)
    end
    

    module Accessor

      def [](obj)
        ret = super
        if ret.kind_of?(Array) and ret.size == 1
          ret = ret.first
        end
        ret
      end
      
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
          if b.kind_of?(Hash) or b.kind_of?(Helper::Dictionary)
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
          [:p, :replace, :id, :clear, :display].each do |m|
            self.send(:undef_method, m)
          end
        end
        self
      end


      def read(&blk)
        instance_eval(&blk)
        self
      end


      def method_missing(m, *args, &b)
        args = Parser.config_hash if args.empty?
        m = m.to_s.gsub(/=$/, '').to_sym
        if not self.keys.include?(m)
          self[m] = args
        end
        self[m].read(&b) if block_given? #and self[m].respond_to?(:read)
        self[m]
      end


      def self.config_hash
        dict = Helper::Dictionary.new
        dict.extend(Parser)
        dict.extend(Accessor)
        dict.cleanup
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
        r = instance_eval(str)
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
