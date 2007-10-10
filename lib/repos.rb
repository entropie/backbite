#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro


  # A Repository may an (un)initiated directory structure, a place for plugins,
  # data files and stuff like this. Each tumblog has excatly one repository.
  class Repository

    attr_reader :directory

    BaseDirs = %w(plugins components htdocs tmp spool)
    
    def initialize(directory)
      @directory = Pathname.new(directory)
    end

    def setup
      BaseDirs.each do |bdir|
        @directory.mkdir(bdir)
      end
    end
    
    def valid?
      @directory.exists?
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
