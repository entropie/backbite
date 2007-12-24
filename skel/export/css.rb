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
        #p ftype
        tree = Tree.new(ftype, tlog, params)
        tree.write
        ret << tree
        retstr << tree.to_s
      }
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
            file = tlog.repository.join("misc", @ofile)
            if file.exist?
              Sass::Engine.new(file.readlines.join).render
            else
              Warn << "#{file} does not exist."
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
        Debug << " ExportTree::CSS parsing file: `#{@filename}'"
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
        Debug << "ExportTree::CSS parsing file: `#{@filename}'"        
        retstr = "/* \n   CSS file: `#{@filename}'\n"
        retstr << "   Autogenerated file; silly to edit. \n*/\n\n"

        # independent definitions
        (cfg = @tlog.config[:html][:body][:independent]).each_pair do |n, pls|
          next unless Plugin::AutoFieldNames.include?(n.to_sym)
          
          cfg[n].each_pair do |n, vals|
            retstr << "  /* BasePlugin: `#{n}' */\n" if $DEBUG
            retstr << "    ##{n} {\n"
            vals[:style].sort.each do |de, na|
              retstr << "      %s:%s;\n" % [de, na]
            end
            retstr << "    }\n"
            retstr << "  /* End BasePlugin `#{n}' */\n\n" if $DEBUG
          end

        end

        # component basic definitions
        @tlog.components.each do |co|
          retstr << "/* Component: `#{co.name}' */\n" if $DEBUG
          retstr << "   #%s > .%s {\n" % [co.config[:target], co.name]
          if style = co.config[:style]
            style.sort.each { |de, na|
              defi = self.class.sanitize_fieldname(de)
              retstr << "      %s:%s;\n" % [defi, na]
            }
          end
          retstr << "    }\n\n"

          retstr << "  /* Parsing component defined field definitions */\n\n" if $DEBUG
          # Maybe: FIXME
          co.fields.each do |fn, fc|
            to, ord = { }, []
            retstr << "\n    /* Component::#{co.name}::Field::#{fn.to_sym} */\n" if $DEBUG
            retstr <<  "    #%s > .%s > .%s {\n" % [co.config[:target], co.name, fn.to_sym]


            # first grab plugin defaults
            if pl = co.plugins[fn.name]
              defs = tlog.config[:defaults][:automatic][:plugins][pl.name][:style]
              ord.push(*defs.sort.map{ |f| f.first })
              to.merge!(defs)
            end

            # overwrite with component defs
            if defstyle = fn.definitions[:style]
              ord.push(*defstyle.sort.map{ |f| f.first })
              to.merge!(defstyle)
            end

            ord.uniq.each do |of|
              dn, m = self.class.sanitize_fieldname(of), to[of]
              retstr << "     %s:%s;\n" % [dn, m]
            end
            retstr << "    }\n"

          end
          retstr << "/* END Component::#{co.name} */\n\n\n\n" if $DEBUG
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
