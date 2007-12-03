#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    # CacheAble is a helper to cache results for faster reuse.
    #
    # == Example
    #  class Foo
    #
    #    include Helper::CacheAble
    #
    #    attr_reader :name
    #
    #    def initialize
    #      @name = :uniq
    #    end
    #
    #    def do_something
    #      Cache(name) do
    #        ...
    #      end
    #    end
    #
    #  end
    module CacheAble

      def Cache(key, &blk)
        cache(self).cache_key(key, &blk)
      end

      def self.cachefile=(file)
        const_set(:CacheFile, file) unless const_defined?(:CacheFile)
      end

      def self.cachefile
        if const_defined?(:CacheFile)
          const_get(:CacheFile)
        else
          '/tmp/backbite.pstore'
        end
      end

      
      class Cache # :nodoc: All
        attr_reader :cachefile
        
        def initialize(cls)
          @klaz = cls
          @cache = PStore.new(cachefile.to_s)
        end

        def cachefile
          @cachefile ||= CacheAble.cachefile
        end
        
        def cache_key(key, &blk)
          @cache.transaction do
            if @cache[key].nil?
              #Debug << "CCache << #{key}"
              self[key] = blk.call              
            else
              #Debug << "UCache << #{key}"
              self[key]
            end
          end
        end

        def [](key)
          return nil unless key
          @cache[key]
        end

        def []=(key,value)
          @cache[key] = value
        end
        
      end
      
      def __mk_cache(cls)
        unless cls.class.const_defined?(:CacheData)
          cls.class.const_set(:CacheData, Cache.new(cls))
        end
        cls.class.const_get(:CacheData)
      end
      private :__mk_cache


      def cache(cls)
        __mk_cache(cls)
      end
      private :cache
      
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

