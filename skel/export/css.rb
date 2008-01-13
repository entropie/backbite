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
      dfs = {
        :generated => { :media => :screen },
        :base => { :media => :screen }
      }

      tlog.config[:stylesheets][:screen].each do |n|
        dfs.merge!(n => { :media => :screen})
      end
      dfs.each_pair { |ftype, m|
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
        definition_for
        @__result__ = @str
      end

      def definition_for
        @str <<
          case @ofile
          when :generated
            generated_definitions << "\n/* EOF: #{@filename} */\n\n\n"
          when :base
            generated_base << "\n/* EOF: #{@filename} */\n\n\n"
          when /\.(haml|sass)$/
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
