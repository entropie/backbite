#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Tumblelog


    include Helper


    attr_reader :repository, :config, :name
    

    def root
      path = @config[:defaults][:root]
      path = ::File.expand_path(path) if path =~ /^\~/
      Pathname.new(path)
    end
    alias :path :root


    def http_path(path = '')
      URI.join(@config[:defaults][:base_href], path)
    end
    

    def author
      @config[:defaults][:author]
    end


    def url
      @config[:defaults][:base_href]
    end

    
    def initialize(name, fdata)
      @name = name
      @config = Config.read(fdata)
      @repository =
        Repository.new(@name, @config[:defaults][:root])
      Helper::CacheAble.cachefile = @repository.join("#{ @name }.pstore")
      @repository.tlog = self
    end
    

    def components
      @components ||= @repository.components
    end


    def posts(params = { }, &blk)
      @repository.posts(params).each { |co|
        yield co
      } if block_given?
      @repository.posts(params)
    end


    def post(component, params = { })
      params.extend(ParamHash).
        process!(:way => :optional,
                 :to => :optional,
                 :hash => :optional,
                 :file => :optional,
                 :meta   => :optional)
      params[:way] ||= :hash
      params[:to]  ||= @repository.join('spool')
      components[component.to_sym].post(params)
    end


    def config_with_replace
      config = @config.with_replacer
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
