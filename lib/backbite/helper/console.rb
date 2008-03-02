#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module Console

      require 'irb'

      def self.start_session(const = Backbite)
        IRB.start_session(const)
      end

      module IRB

        include ::IRB

        # http://errtheblog.com/posts/9-drop-to-irb
        def self.start_session(const)
          ::IRB.setup(nil)
          workspace = ::IRB::WorkSpace.new(const)
          conf = ::IRB.instance_variable_get("@CONF")
          irb  = ::IRB::Irb.new(workspace)
          conf[:IRB_RC].call(irb.context) if conf[:IRB_RC]
          conf[:MAIN_CONTEXT] = irb.context

          trap("SIGINT") do
            irb.signal_handle
          end

          catch(:IRB_EXIT) do
            irb.eval_input
          end
        end
      end
    end
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
