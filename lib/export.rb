#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Repository::Export

    require 'lib/export/html.rb'

    def export(way)
      way = way.to_s.upcase
      cway = Repository::Export::const_get(way)
      @export = if cway
        cway.export(tlog)
      else
        raise "#{way} is unknown"
      end
    end

    def to_s
      @export.to_s
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
