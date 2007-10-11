#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Plugins < Array
    def [](o)
      select{|pl| pl.name.split('::').last.downcase == o }.shift
    end
  end
  
  class Plugin
    def self.inherited(o)
      @@rets << o
    end
    
    def self.load(plugin_file)
      @@rets = Plugins.new
      eval(File.open(plugin_file).readlines.to_s)
      @@rets.last
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
