#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


$:.unshift(File.dirname(__FILE__))
require 'pp'
require 'pathname'
require 'fileutils'
begin 
  require 'rubygems' 
rescue LoadError
end

begin
  require 'log4r'
  require 'log4r/configurator'
  Log4r::Configurator.custom_levels(:Debug, :Notice, :Info, :Msg, :Error, :Fatal)
  require 'log4r/outputter/syslogoutputter'
rescue LoadError
end

# :include:../README.rdoc
module Backbite

  GlobalDefaults = { :colors => true }

  StartedAt = Time.now
  
  def self.wo_debug
    begin
      s, $DEBUG = $DEBUG, false
      yield self
    ensure
      $DEBUG = s
    end
  end
  
  Version = %w'0 4 7'

  Source  = Pathname.new(File.dirname(File.expand_path(__FILE__))).parent

  def self.exit(code_or_codename = 23)
    Kernel.exit(code_or_codename)
  end
  
  def self.version
    "backbite-#{Version.join('.')}"
  end

  def register
    @register ||= Register.new
  end

  module_function :register
  def self.require_libs
    wo_debug do
      begin
        require 'pstore'
        require 'abbrev'
        require 'delegate'
        require 'uri'
        require 'yaml'
        require 'readline'
      rescue LoadError
        warn "Backbite: " + $!.to_s
        exit 23
      end
    end

    %w(globals ruby_ext informer exception settings contrib helper textfilter
       ways post components plugins repos export tumblog arguments generator
       register archive).each do |lfile|
      require "backbite/" + lfile
    end
  end
  require_libs

  begin
    wo_debug { require 'haml' }
  rescue LoadError
    Info << "No haml support."
    globals[:support_haml] = false
  end

  $DEBUG = Backbite.globals.debug? or false

  include Helper::Text
  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
