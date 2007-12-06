#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

$:.unshift(File.dirname(__FILE__))

$DEBUG = true if ENV['DEBUG']

require 'pp'
require 'pathname'
require 'fileutils'

begin
  require 'log4ra'
  require 'log4r/outputter/syslogoutputtera'
rescue LoadError
  $DEBUG = false
end

require 'hpricot'
require 'delegate'
require 'uri'
require 'yaml'
require 'readline'
require 'haml'
require 'pstore'
require 'abbrev'

require 'backbite/ruby_ext'
require 'backbite/helper'
require 'backbite/settings'
require 'backbite/ways'
require 'backbite/post'
require 'backbite/components'
require 'backbite/informer'
require 'backbite/plugins'
require 'backbite/repos'
require 'backbite/export'
require 'backbite/tumblog'
require 'backbite/arguments'
require 'backbite/generator'
require 'backbite/register'
Dir['lib/ruby_ext/*.rb'].each do |re|
  require re
end



module Backbite

  Version = %w'0 1 7'

  Source  = Pathname.new(File.dirname(File.expand_path(__FILE__))).parent

  def self.version
    "backbite-#{Version.join('.')}"
  end

  if $DEBUG
    Informer.create << "starting logger for backbite, #{version.to_s}."
    Debug << "debugmode is on."
  end

  def register
    @register ||= Register.new
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
