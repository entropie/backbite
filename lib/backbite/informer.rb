#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

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

    if defined? Log4r
      class Formatter < Log4r::Formatter # :nodoc: All
        def format(event)
          t, buff = Time.now, ''
          lvl = Log4r::LNAMES[event.level]
          buff << "[".white << "#{"%8s" % t.usec.to_s}".cyan << "]".white
          case lvl
          when 'INFO'
            buff += "  * ".green.bold + event.data.to_s.strip.white
          when 'DEBUG'
            return '' unless $DEBUG
            buff += "  * ".white + event.data.to_s.strip.white
          when 'WARN'
            buff += "!!! ".red.bold + event.data.to_s.strip.white.bold
          end
          buff << "\n"
        end
      end

    else
      class StdoutLogger
      end
    end

    # Creates the logger.
    def self.create
      new
      self
    end

    def get_logger
      @logger =
        if defined? Log4r
          Log4r::Logger.new 'backbite'
        else
          StdoutLogger.new
        end
    end
    
    def initialize
      get_logger
      choose_outputter
    end

    def choose_outputter
      begin
        if defined? Log4r
          if defined? Spec
            @logger.outputters = Log4r::SyslogOutputter.new('backbite')
          else
            op = Log4r::StdoutOutputter.new('backbite')
            op.formatter = Formatter
            @logger.outputters = op
          end
        end
      end
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
      if defined? Log4r and lgr = Log4r::Logger['backbite']
        lgr.send(lvl, msg)
      else
        $stdout.puts "%10s: %s" % [lvl, msg]
      end
    rescue
      #puts $!
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

  Informer.create
  Debug << "Starting logger for backbite."
  Debug << "debugmode is on."
  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
