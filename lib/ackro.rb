#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'pp'
require 'pathname'
require 'fileutils'
require 'log4r'
require 'yaml'

require 'lib/helper'
require 'lib/settings'
require 'lib/components'
require 'lib/informer'
require 'lib/repos'
require 'lib/tumblog'


Dir['lib/ruby_ext/*.rb'].each do |re|
  require re
end

$DEBUG = true if ENV['DEBUG']

module Ackro

  Version = %w'0 1 1'

  Source  = Pathname.new(File.dirname(File.expand_path(__FILE__))).parent
  
  def self.version
    "ackro-version-#{Version.join('.')}"
  end

  Informer.create << "starting logger for ackro.succ, #{version.to_s}."
  Debug << "debugmode is on." if $DEBUG
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
