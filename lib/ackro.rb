#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'pp'
require 'lib/settings'

Dir['lib/ruby_ext/*.rb'].each do |re|
  require re
end

module Ackro
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
