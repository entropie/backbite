#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro


  # A Repository may an (un)initiated directory structure, a place for plugins,
  # data files and stuff like this. Each tumblog has excatly one repository.
  class Repository

    include Helper
    
    attr_reader :directory, :name

    attr_accessor :tlog
    
    BaseDirs = %w(plugins components htdocs tmp spool)
    
    def initialize(name, directory)
      @name, @directory = name.to_sym, Pathname.new(directory)
    end

    def inspect
      "#{@directory.to_s}"
    end

    def posts(params = { })
      (par = join('spool')).entries.reject{ |e| e.to_s =~ /^\.+/ }.
        inject([]) do |ma, f|
        Ways.dispatch(:yaml) do |way|
          way.tlog = @tlog
          way.source = YAML::load(par.join(f).readlines.join)
        end.process(params, self)
        
      end
    end
    
    def components
      #raise "not a valid repos yet" unless join(:components).exist?
      @components ||= Components.load(join(:components), tlog)
    end

    def join(other_dir)
      dir = Pathname.new(::File.expand_path(@directory))
      dir.join(other_dir.to_s)
    end
    
    # unlinks everthing in our repos directory
    def remove!
      Info << "say bye to your repos in 5 seconds..."
      sleep 5 unless $DEBUG
      `rm -rv #{directory}`
      Info << "repos removed."
    end
    
    # Creates a directory structure for the repos.
    def setup!
      Info << "Creating directory structure for `#{name}`"
      @directory = Helper::File.ep(@directory)
      @directory.mkdir and (Info << "created #{@directory}") unless @directory.exist?
      populate!      
      BaseDirs.each do |bdir|
        ndir = @directory.dup.join(bdir.to_s)
        if ndir.exist?
          Info << " Subdirectory `#{name}/#{bdir}` is existing."
          next
        end
        ndir.mkdir and
          Info << " Created subdirectory `#{name}/#{bdir}`."
      end
      Info << "Done, `#{name}` should be valid repository now."
    end

    # Copy defaults to repos.
    def populate!
      Info << "populating directory structure with defaults for `#{name}`"

      source =
        if defined?(Spec)
          Ackro::Source.join('spec_skel')
        else
          Ackro::Source.join('skel')
        end
      %w'plugins components'.each do |w|
        (st = source.join(w)).entries.grep(/^[^\.]/).each do |e|
          Info << " cp #{st.join(e)} to #{w}/#{e}"
          t = @directory.join(w)
          system("mkdir -p #{t} && cp #{st.join(e).to_s} #{t}/")
        end
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
