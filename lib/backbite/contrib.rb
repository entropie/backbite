#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Contrib

    LOADED_CONTRIBS = { }

    DPATTERN = /^[^\.]/

    CONTRIB_DIR = Source.join('lib', 'contrib')


    def self.path_of(name)
      CONTRIB_DIR.join(name.to_s)
    end

    def self.reset
      LOADED_CONTRIBS.clear
    end
    
    def self.loaded_contribs
      LOADED_CONTRIBS
    end

    def self.load(dir, name, from = CONTRIB_DIR)
      name = name.to_s      
      unless loaded_contribs.include?(name)
        name.gsub!(/\.rbx?/, '')
        path = from.join(dir, 'lib', "#{name}.rb")
        require(path)
        const = const_get(name.capitalize)
        LOADED_CONTRIBS[dir] = const
        const
      else
        return LOADED_CONTRIBS.fetch(name)
      end
    end
    
    def self.all
      CONTRIB_DIR.entries.grep(DPATTERN).each do |cdir|
        const = nil
        dir = cdir.to_s
        CONTRIB_DIR.join(cdir, 'lib').entries.grep(/\.rb$/).each do |rf|
          load(dir, rf)
        end
      end
      LOADED_CONTRIBS
    end
    
    def self.[](obj)
      ret = all.select{ |a,c| a.to_s =~ /#{obj}/i }
      ret.flatten.last
    end
  end

end

# %w(pyr).each do |l|
#   require "backbite/contrib/"+ l
# end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
