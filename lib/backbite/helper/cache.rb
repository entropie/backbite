#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module CacheAble

      class Cache

        def initialize
          @cache = { }
        end
        
        def cache_key(key, &blk)
          rkey = key.to_sym
          Info << " Cache: reciving cache request for `#{rkey}"          
          unless @cache[rkey]
            Info << " Cache: creating cache for `#{rkey}"
            @cache[rkey] = blk.call
          else
            Info << " Cache: usic cached obj: `#{rkey}"
          end
          @cache[rkey]
        end

        def [](key)
          key = key.to_sym
          @cache.select{ |hkey, hval| hkey == key }.first.last
        end
        
      end


      def Cache(key, &blk)
        ccache = cache(self.class)
        ccache.cache_key(key, &blk)
      end


      def __mk_cache(cls)
        unless cls.const_defined?(:CacheData)
          p 1
          cls.const_set(:CacheData, Cache.new)
        end
        cls.const_get(:CacheData)
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
