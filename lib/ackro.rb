#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'pp'
require 'pathname'
require 'log4r'
require 'lib/settings'
require 'lib/informer'
require 'lib/repos'

Dir['lib/ruby_ext/*.rb'].each do |re|
  require re
end

module Ackro
  Version = %w'0 1 1'

  def self.version
    "ackro-version-#{Version.join('.')}"
  end

  Informer.create << "starting logger for ackro.succ, #{version.to_s}."
  Debug << "debugmode is on" if $DEBUG
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
