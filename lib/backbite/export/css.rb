#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Repository::Export::CSS
    # mount point
    def self.export(tlog, params)
      ret = []
      retstr = ''
      dfs = { :generated => { :media => :screen }, :base => { :media => :screen}}
      dfs.merge(tlog.config[:stylesheets][:files]).each_pair { |ftype, m|
        tree = Tree.new(ftype, tlog, params)
        tree.write
        ret << tree
        retstr << tree.to_s
      }

      
      tlog.config[:stylesheets][:file].each do |sfile|
        rfile = tlog.repository.join(sfile)
        tree = Tree.new(sfile, tlog, params)
        tree.write
        ret << tree
        retstr << tree.to_s
      end
      retstr
    end

    class Tree < Repository::ExportTree # :nodoc: All

      def initialize(file, tlog, params)
        @ofile = file
        @filename = tlog.http_path("include/%s.css" % file).to_s
        super(tlog, params)
        @file = "include/#{file}.css"
        @str = ''
        definition_for(file)
        @__result__ = @str
      end

      def definition_for(file)
        @str <<
          case file
          when :generated
            generated_definitions << "\n/* EOF: #{@filename} */\n\n\n"
          when :base
            generated_base << "\n/* EOF: #{@filename} */\n\n\n"
          when /\.haml/
            file = tlog.repository.join(@ofile)
            if file.exist?
              Sass::Engine.new(file.readlines.join).render
            else
              ''
            end
          else
            Info << " Ingoring #{self.class}#definition: #{file}"
            ''
          end
      end

      def self.sanitize_fieldname(fname)
        fname.to_s.gsub(/_/, '-')
      end

      def generated_base
        Info << " ExportTree::CSS parsing for file: `#{@filename}'"
        retstr = "/* \n   CSS file: `#{@filename}'\n"
        retstr << "   Autogenerated file; silly to edit. \n*/\n\n"
        tconf = @tlog.config_with_replace[:html][:body][:style]
        if tconf.empty?
        else
          retstr << "body {\n"
          tconf.each_pair { |de, na|
            retstr << "  %s:%s;\n" % [self.class.sanitize_fieldname(de), na]
          }
          retstr << "}\n"
        end

        (tc = @tlog.config_with_replace[:html][:body]).each_pair{ |n, v|
          next if n == :style
          t = tc[n][:style]
          if t.empty?
          else
            retstr << "  /* Node: `#{n}' */\n"
            retstr << "  #%s {\n" % n
            t.each_pair do |sn, sv|
              retstr << "    %s:%s;\n" % [self.class.sanitize_fieldname(sn), sv]
            end
            retstr << "  }\n  /* END Node: `#{n}' */\n\n"
            
          end
        }
        retstr
      end
      
      def generated_definitions
        retstr = "/* \n   CSS file: `#{@filename}'\n"
        retstr << "   Autogenerated file; silly to edit. \n*/\n\n"
        Info << "ExportTree::CSS parsing for file: `#{@filename}'"


        # component basic definitions
        @tlog.components.each do |co|
          retstr << "  /* Component: `#{co.name}' */\n"
          retstr << "    #%s > .%s {\n" % [co.config[:target], co.name]
          t = co.config[:style]
          co.config[:style].each_pair { |de, na|
            defi = self.class.sanitize_fieldname(de)
            retstr << "      %s:%s;\n" % [defi, na]
          }
          retstr << "    }\n  /* End component `#{co.name}' */\n\n"            
        end

        retstr << "  /* Parsing component defined field definitions */\n\n"

        # per field definitions
        @tlog.components.each do |co|
          co.fields.each do |fn, fc|
            retstr << "  /* Component::#{co.name}::Field::#{fn.to_sym} */\n"
            retstr <<  "    #%s > .%s > .%s {\n" %
              [co.config[:target], co.name, fn.to_sym]
            fn.definitions[:style].each { |n, m|
              dn = self.class.sanitize_fieldname(n)
              retstr << "     %s:%s;\n" % [dn, m]
            }
            retstr << "    }\n  /* END Component::#{co.name}::Field::#{fn.to_sym} */\n\n"
          end
        end
        retstr
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
