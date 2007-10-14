#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class DefaultLogFormatter < Log4r::Formatter
    def format(event)
      buff = Time.now.strftime("%a %m/%d/%y %H:%M %Z")
      buff += " - #{Log4r::LNAMES[event.level]}"
      buff += " - #{event.data}\n"
    end
  end

  
  # Informer handles Logging, thanks to Log4r, once it's instantiated
  # we don't need to keep track of the instance.
  #
  # To finally do the log, pick one of the Subclasses of Informer and
  #  Debug << "a debug message"
  #  Error << "a error message"
  #
  # == Level
  # * Debug
  # * Info
  # * Warn
  # * Error
  # * Fatal
  class Informer
    
    # Creates the logger.
    def self.create
      new
      self
    end

    def initialize
      @logger = Log4r::Logger.new 'ackro' #, :formatter=> DefaultLogFormatter
      @logger.outputters = Log4r::SyslogOutputter.new('ackro')
    end

    def self.log(msg)
      level =
        if name =~ /informer$/i then :info
        else
          name.to_s.split('::').last.downcase.to_sym
        end
      do_log(level, msg)
      self
    end

    class << self
      alias :<< :log
    end
    
    def self.do_log(lvl, msg)
      if lvl == :debug
        lvl = :info
      end
      Log4r::Logger['ackro'].send(lvl, msg)
    end
    
  end

  class Debug < Informer # :nodoc: All
  end

  class Info  < Informer # :nodoc: All
  end

  class Warn  < Informer # :nodoc: All
  end

  class Error < Informer # :nodoc: All
  end

  class Fatal < Informer # :nodoc: All
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
