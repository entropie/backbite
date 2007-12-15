#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Globals are used to save overall data and to addept enviroment variables.
  
  class Globals < Hash

    # the list of known variables
    Globs = [:colors, :force, :debug, :support_haml]

    def initialize(env = ENV)
      @env = env
      set_defaults
    end

    private
    def set_defaults
      Globs.each do |glbl|
        self[glbl] = Backbite::GlobalDefaults[glbl] || false
        self.class.send(:define_method, "#{glbl}?") {
          self[glbl]
        }
        if glblval = @env[glbl.to_s.upcase]
          value =
            case glblval
            when "0", "false", "no" then false
            when "1", "true", "yes" then true
            else
              Backbite::GlobalDefaults[glbl] || false
            end
          self[glbl] = value
        end
      end
    end
  end

  GLOBALS = Globals.new(ENV)

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
