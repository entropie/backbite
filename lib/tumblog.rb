#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Tumblelog

    include Helper

    attr_reader :repository, :config, :name
    

    def root
      @config[:defaults][:root]
    end
    alias :path :root

    
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
      @repository.tlog = self
    end
    

    def components
      @components ||= @repository.components
    end


    def posts(params = { }, &blk)
      @repository.posts.each { |co|
        yield co
      } if block_given?
      @repository.posts
    end
    

    def post(component, params = { })
      params.extend(ParamHash).
        process!(:way => :optional,
                 :to => :optional,
                 :hash => :optional,
                 :string => :optional)
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
