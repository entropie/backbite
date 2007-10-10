#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Tumblelog

    include Helper
    
    def initialize(name, fdata)
      @name = name
      @config = Configurations.read(fdata)
      @repository =
        Repository.new(@name, @config[:defaults][:root])
      p components
    end

    def components
      @components ||= @repository.components
    end
    
    def post(component, params = { })
      params.extend(ParamHash).
        process!(:way => :optional, :to => :optional)
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
