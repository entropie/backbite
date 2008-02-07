#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Generate file skeletons  for Tumblelog, Components and Plugins
  module Generators

    UnknownGenerator = Backbite::NastyDream(self)

    def self.[](obj)
      generators do |name, gen|
        return gen if obj.to_sym == name.to_sym
      end
      nil
    end
    
    def self.generators
      Generators.constants.map{ |const|
        gen = Generators.const_get(const)
        name = gen.to_s.split('::').last.downcase
        next if gen == UnknownGenerator
        yield name, gen
      }
    end

    def self.generate(name, what, tlog)
      tconst = if what.class === Class then what else what.class end
      tconst = tconst.to_s.split('::').last
      if const = Generators.const_get(tconst) and const != NilClass
        return what.extend(const).make(name, tlog)
      else
        raise UnknownGenerator, what
      end
    end

    module Tumblelog
      def load_tlog(name, file)
        Tumblelog.new(name, file)
      end
      
      def make(name, tlog)
        efile = Backbite::Source.join('doc', 'exampleconfig.rb')
        cfg = Settings.read(efile)
        tlroot = cfg[:defaults][:root]
        
        econts = efile.readlines.join
        econts.gsub!(/(__name__)/, name.to_s)
        econts
      end
    end
    
    module Component
      def make(name, tlog)
        res = ''
        res << "define(:#{name}) do\n"
        res << (prfx=" "*2) << "\n"
        res << prfx << "target :content_node # edit me!\n\n"
        res << prfx << "style {\n#{prfx}}\n\n"
        res << prfx << "fields {\n#{prfx}}\n\n"
        res << "end\n\n"
      end
    end

    module Plugin
      def make(name, tlog)
        res = ''
        res << "class #{name.to_s.capitalize} < Plugin\n\n"
        [:metadata_inject, :input, 'transform!(str)', :content,
         :before, :after, :filter].each do |defun|
          res << (p=" "*2) << "# def #{defun}\n#{p}# end\n\n"
        end
        res << "end\n\n"
      end
    end

    module Post
      Fieldskel = "[%field%_start]\n\n[%field%_end]"
      def make(name, tlog)
        res = ''
        comp = tlog.components[name.to_sym]
        raise Component::ComponentNotKnown, name unless comp
        comp.fields.each do |fn|
          next if fn.interactive?
          name = fn.to_sym
          str = Fieldskel.gsub(/%(field)%/, name.to_s)
          res << str << "\n\n\n"
        end
        res
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
