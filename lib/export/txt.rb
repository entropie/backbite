#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Ackro

  module Repository::Export::TXT

    # mount point
    def self.export(tlog, params)
      Tree.new(tlog, params)
    end
    
    class Tree

      attr_reader :tlog, :hpricot, :timestamp
      
      def initialize(tlog, params)
        @tlog, @params = tlog, params
        @timestamp = Time.new
        @str = "# ''#{params[:title]}`` at '#{timestamp}'\n\n"
      end

      def to_s
        @str
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
