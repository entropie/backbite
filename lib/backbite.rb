#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

$:.unshift(File.dirname(__FILE__))


require 'pp'
require 'pathname'
require 'fileutils'
require 'rubygems'



begin
  require 'log4r'
  require 'log4r/outputter/syslogoutputter'
rescue LoadError
  $DEBUG = false
else
  $DEBUG = true if ENV['DEBUG']
end

module Backbite

  GlobalDefaults = { :colors => true }
  
  def self.wo_debug
    begin
      s, $DEBUG = $DEBUG, false
      yield self
    ensure
      $DEBUG = s
    end
  end

  Version = %w'0 2 9'

  Source  = Pathname.new(File.dirname(File.expand_path(__FILE__))).parent
  
  def self.version
    "backbite-#{Version.join('.')}"
  end

  def register
    @register ||= Register.new
  end

  def self.require_libs
    wo_debug do
      begin
        require 'pstore'
        require 'abbrev'
        require 'hpricot'
        require 'delegate'
        require 'uri'
        require 'yaml'
        require 'readline'
      rescue LoadError
        warn "Backbite: " + $!.to_s
        exit 23
      end
    end
    

    require 'backbite/globals'
    require 'backbite/ruby_ext'
    require 'backbite/informer'
    require 'backbite/exception'
    require 'backbite/helper'
    require 'backbite/settings'
    require 'backbite/ways'
    require 'backbite/post'
    require 'backbite/components'
    require 'backbite/plugins'
    require 'backbite/repos'
    require 'backbite/export'
    require 'backbite/tumblog'
    require 'backbite/arguments'
    require 'backbite/generator'
    require 'backbite/register'
  end
  require_libs

  begin
    wo_debug { require 'haml' }
  rescue LoadError
    Info << "No haml support."
    globals[:support_haml] = false
  end

end




# Dir['lib/ruby_ext/*.rb'].each do |re|
#   require re
# end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
