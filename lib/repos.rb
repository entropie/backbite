#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro


  # A Repository may an (un)initiated directory structure, a place for plugins,
  # data files and stuff like this. Each tumblog has excatly one repository.
  class Repository

    attr_reader :directory, :name

    attr_accessor :tlog
    
    BaseDirs = %w(plugins components htdocs tmp spool)
    
    def initialize(name, directory)
      @name, @directory = name.to_sym, Pathname.new(directory)
    end

    def inspect
      "#{@directory.to_s}"
    end

    def components
      @components ||= Components.load(join(:components), tlog)
    end

    def join(other_dir)
      dir = Pathname.new(File.expand_path(@directory))
      dir.join(other_dir.to_s)
    end
    
    # unlinks everthing in our repos directory
    def remove!
      Warn << "say bye to your repos in 5 seconds..."
      sleep 5 unless $DEBUG
      `rm -r #{directory}`
      Info << "repos removed."
    end
    
    # Creates a directory structure for the repos.
    def setup!
      Info << "creating directory structure for #{name}"
      @directory = Helper::File.ep(@directory)
      @directory.mkdir and (Info << "created #{@directory}") unless @directory.exist?
      populate!      
      BaseDirs.each do |bdir|
        ndir = @directory.dup.join(bdir.to_s)
        if ndir.exist?
          Info << "subdirectory #{name}/#{bdir} is existing."
          next
        end
        ndir.mkdir and
          Info << "created subdirectory #{name}/#{bdir}"
      end
      Info << "done, #{name} should be valid now"
    end

    # Copy defaults to repos.
    def populate!
      Info << "populating directory structure with defaults for #{name}"
      source = Ackro::Source.join('skel')
      begin
        FileUtils.cp_r(source.to_s + "/.", @directory.to_s+ "/")
      rescue Exception
      end
    end
    private :populate!
    
    # Checks wheter our actual repos is valid or not.
    def valid?
      @directory.exist? and
        @directory.entries.reject{ |d| d.to_s =~ /^\.+/ }.
        map{ |d| d.to_s } == BaseDirs
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
