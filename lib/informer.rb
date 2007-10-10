#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Informer

    def self.create
      new
      self
    end
    
    def initialize
      @logger = Log4r::Logger.new 'ackro'
      @logger.outputters = Log4r::Outputter.stdout
    end

    def self.<<(msg)
      level =
        if name =~ /informer$/i then :info
        else
          name.to_s.split('::').last.downcase.to_sym
        end
      do_log(level, msg)
    end

    def self.do_log(lvl, msg)
      Log4r::Logger['ackro'].send(lvl, msg)
    end
    
  end

  class Debug < Informer
  end

  class Warn  < Informer
  end

  class Error < Informer
  end

  class Fatal < Informer
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
