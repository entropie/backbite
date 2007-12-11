#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Globals < Hash

    Globs = [:colors]

    def initialize
      Globs.each do |glbl|
        self[glbl] = true
        self.class.send(:define_method, "#{glbl}?") {
          self[glbl]
        }
      end
    end
    
  end

  GLOBALS = Globals.new

  def self.globals
    GLOBALS
  end

  def self.[]=(globalkey, value)
    globals[globalkey.to_sym] = value
  end
  
  def self.[](globalkey)
    globals[globalkey.to_sym]
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
