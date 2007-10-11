#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  # Informer handles Logging, thanks to Log4r, once it's instantiated
  # we don't need to keep track of the instance.
  #
  # To finally do the log, pick one of the Subclasses of Informer and
  #  Debug << "a debug message"
  #  Error << "a error message"
  class Informer

    # Creates the logger.
    def self.create
      new
      self
    end

    def initialize
      @logger = Log4r::Logger.new 'ackro'
      @logger.outputters = Log4r::Outputter.stdout
    end

    def self.log(msg)
      level =
        if name =~ /informer$/i then :info
        else
          name.to_s.split('::').last.downcase.to_sym
        end
      do_log(level, msg)
    end

    class << self
      alias :<< :log
    end
    
    def self.do_log(lvl, msg)
      #Log4r::Logger['ackro'].send(lvl, msg)
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
