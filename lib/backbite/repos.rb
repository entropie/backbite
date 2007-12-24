#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite


  # A Repository may an (un)initiated directory structure, a place for plugins,
  # data files and stuff like this. Each tumblog has exactly one repository.
  class Repository

    include Helper
    

    attr_reader :directory, :name


    attr_accessor :tlog
    
    IgnoredBodyFields = [:style, :independent]
    
    # Basically a list of names
    BaseDirs = %w(export plugins components htdocs tmp spool misc)


    SubDirs  = { :htdocs => [:include], :tmp => ['.work'] }

    def initialize(name, directory)
      @name, @directory = name.to_sym, Pathname.new(directory)
    end


    def export(way = nil, params = { })
      return dup.extend(Export) unless way
      params[:path_deep] ||= './'
      params[:title] ||= "[no title]"
      dup.extend(Export).export(way, params)
    end


    def to_s
      tas  = [ ['Posts'.cyan, @tlog.posts.size.to_s.magenta], ['Components'.cyan, @tlog.components.size.to_s.magenta]]
      s, se = `du -sh #{@directory}`.split("\t").first
      rstr = "#{'Repository'.green.bold} #{@directory.to_s.bold} #{'Size'.cyan}:#{s.magenta}"
      tas.inject(rstr) { |m,v|
        m << " " << v.join(':')
      }
      
    end


    #def to_s end


    # Return a list of Posts
    def posts(params = { }, &blk)
      Posts.new(@tlog).filter(params, &blk)
    end


    # Returns a list of every known Component
    def components
      raise "not a valid repos yet" unless join(:components).exist?
      @components ||= Components.load(join(:components), tlog)
    end


    # returns pathname instance of working dir
    def working_dir(*other)
      join('tmp', '.work', *other)
    end
    

    # Returns a Pathname instance, the Repository path joined with
    # +other_dirs+.
    def join(*other)
      @directory.join(*other.map(&:to_s))
    end


    # unlinks everthing in our repos directory
    # FIXME
    def remove!
      Info << "say bye to your repos in 5 seconds..."
      sleep 5 unless $DEBUG
      `rm -rv #{directory}`
      Info << "repos removed."
    end
    

    # removes temporary files
    def clean!
      fc, toclean = 0, [:tmp]
      toclean.each do |tc|
        (base = join(tc)).entries.each do |te|
          file = base.join(te)
          next if file.directory?
          if file.extname == '.tmp' and file.unlink
            fc+=1
          end
        end
      end
      fc
    end

    
    # Creates a directory structure for the repos.
    def setup!
      Info << "Creating directory structure for `#{name}`"
      @directory = Pathname.new(File.expand_path(@directory))
      @directory.mkdir and (Info << "created #{@directory}") unless @directory.exist?
      
      BaseDirs.each do |bdir|
        ndir = @directory.dup.join(bdir.to_s)
        if ndir.exist?
          Info << " Subdirectory `#{name}/#{bdir}` is existing."
          next
        end
        ndir.mkdir and Info << " Created subdirectory `#{name}/#{bdir}`."
        if sdirs = SubDirs[bdir.to_sym]
          sdirs.each do |sdir|
            (s = ndir.join(sdir.to_s)).mkdir
            Info << " Created subdirectory `#{name}/#{bdir}/#{s.basename.to_s}`."
          end
        end
      end
      populate!
      Info << "Done, `#{name}` should be valid repository now."
      Info << "Yes Sir, it is!" if valid?
      self
    end


    # Copy defaults to repos.
    def populate!
      Info << "populating directory structure with defaults for `#{name}`"

      sources =
        if defined?(Spec)
          Info << "!!! using testing skeleton"
          Backbite::Source.join('spec/.spec_skel')
        end
      sources = [Backbite::Source.join('skel'), sources].compact

      # additional =
      #   if defined?(Spec)
      #     %w'misc/rspec.haml'
      #   else
      #     %w'misc/backbite.tex'
      #   end
      %w'plugins components export misc'.each do |w|
        sources.each do |source|
          (st = source.join(w)).entries.grep(/^[^\.]/).each do |e|
            t = @directory.join(w)
            if st.join(e).exist? and
                not (Backbite::globals[:force] or defined? Spec)
              Warn << "POPULATE: skipping #{st.join(e).to_s.split('/')[-3..-1].join('/')} (use FORCE=1 to overwrite)"
              next
            end
            Info << " cp #{st.join(e)} to #{w}/#{e}"            
            system("mkdir -p #{t} && cp #{st.join(e).to_s} #{t}/")
          end
          # additional.each do |a|
          #   p("cp #{source.join(a)} #{@directory} 2>/dev/null")
          # end
        end
      end
    end
    private :populate!
    

    # Checks wheter our actual repos is valid or not.
    def valid?
      @directory.exist? and
        @directory.entries.reject{ |d| d.to_s =~ /^\.+/ or not @directory.join(d).directory? }.
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
