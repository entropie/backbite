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

    attr_reader :logger
    
    if defined? Log4r

      class Formatter < Log4r::Formatter # :nodoc: All
        def format(event)
          @ot ||= Time.now.to_f
          t, buff = (Time.now.to_f-@ot).divmod(1), ''
          @ot = Time.now.to_f
          lvl = Log4r::LNAMES[event.level]
          et = "%05i" % [(t.last*1000000).abs]
          buff << "[".white << " -#{"%3i" % t.first.to_s}.#{et[0..2]}".green << "]".white
          case lvl
          when 'Debug', 'Notice'
            buff += " * ".white + event.data.to_s.strip.white
          when 'Info'
            buff += " * ".green.bold + event.data.to_s.strip.white
          when 'Msg'
            buff += " * ".cyan.bold + event.data.to_s.strip.magenta
          when 'Warn', 'Error', 'Fatal'
            buff += "!!! ".red.bold + event.data.to_s.strip.white.bold
          else
            p lvl
          end
          buff << "\n"
          Backbite.exit if lvl == 'FATAL'
          buff
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
          lgr = Log4r::Logger.new 'backbite'
          lgr.level = (Backbite.globals.debug?||4).to_i
          lgr
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
        if name =~ /informer$/i then :debug
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
    end
  end

  class Debug < Informer # :nodoc: All
  end

  class Notice < Informer # :nodoc: All
  end

  class Info  < Informer # :nodoc: All
  end

  class Msg  < Informer # :nodoc: All
  end

  class Error < Informer # :nodoc: All
  end

  class Fatal < Informer # :nodoc: All
  end


  Informer.create
  Debug << "Starting logger for backbite."
  Debug << "debugmode is on."

  alias :__puts__ :puts
  def puts(*a)
    [a].flatten.each do |ac|
      ac.to_s.split("\n").each do |str|
        Msg << str
      end
    end
  end
  alias :kputs :__puts__

  #Backbite.puts "asd"
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
