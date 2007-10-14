#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Tumblelog

    include Helper

    attr_reader :repository, :config, :name
    
    def initialize(name, fdata)
      @name = name
      @config = Configurations.read(fdata)
      @repository =
        Repository.new(@name, @config[:defaults][:root])
      @repository.tlog = self
    end

    def components
      @components ||= @repository.components
    end

    def posts(params = { }, &blk)
      @repository.posts #.collect(&blk)
    end
    
    def post(component, params = { })
      params.extend(ParamHash).
        process!(:way => :optional, :to => :optional, :array => :optional)
      params[:way] ||= :array
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
