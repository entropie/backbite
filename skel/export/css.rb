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
      stylesheets = {
        :generated => { :media => :screen },
        :base => { :media => :screen }
      }
      tlog.config[:stylesheets].each do |media, value|
        tlog.config[:stylesheets][media].each do |m|
          stylesheets[m] = { :media => :screen}
        end
      end
      
      stylesheets.each_pair { |ftype, m|
        tree = Tree.new(ftype, tlog, params)
        tree.write
        ret << tree
        retstr << tree.to_s
      }
      retstr
    end

    def self.sanitize_def(name)
      name.to_s.gsub(/_/, '-')
    end

    def self.sanitize_val(value)
      value
    end
    
    def self.mk_css_definitions(name, hash, indent = 2)
      ret = "#{name} {\n"
      hash.each_pair do |field, value|
        ret << (" "*indent) << "#{sanitize_def(field)}:#{sanitize_val(value)};\n"
      end
      ret << "}\n\n"
    end

    
    class Tree < Repository::ExportTree

      def initialize(file, tlog, params)
        @out_file = file
        @filename = tlog.http_path("include/%s.css" % file).to_s
        super(tlog, params)
        @file = "include/#{file}.css"
        @str = ''
        definition_for
        @__result__ = @str
      end

      def to_s
        @__result__
      end

      
      def definition_for
        @str <<
          case @out_file
          when :generated
            generated_definitions
          when :base
            generated_base
          when /\.(haml|sass)$/
            file = tlog.repository.join("misc", @out_file)
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

      # generate definitions for components
      def generated_definitions
        ret = ''


        # build definitions defined as default
        if auto = tlog.config[:defaults][:automatic] and 
            plugins = auto[:plugins]
          plugins.each_pair do |pl, prc|
            next unless prc[:value]
            value = prc[:value].call
            ret << Repository::Export::CSS.mk_css_definitions("body .#{pl}", value)
          end
        end
        
        components = tlog.components.each do |co|
          target, style = co.config[:target].first, co.config[:style]
          ret << Repository::Export::CSS.mk_css_definitions("##{target} > .#{co.name}", style)
          co.fields.each do |field|
            name = "#{target} > .#{co.name} > .#{field.to_sym}"
            if field.respond_to?(:definitions) and field.definitions[:style]
              ret << Repository::Export::CSS.mk_css_definitions("##{name}", field.definitions[:style])
            end
          end
        end
        
        ret
      end
      
      # generate definitions for body{} and for each html node
      def generated_base
        ret = ''
        if tlog.config[:html] and tlog.config[:html][:body] and style = tlog.config[:html][:body][:style]
          ret << Repository::Export::CSS.mk_css_definitions('body', style)
        end
        nodes = tlog.config[:html][:body].select{ |k,v| not Repository::IgnoredBodyFields.include?(k.to_sym)}
        styles = nodes.map{ |name, values| [name, values[:style]]}
        styles.each do |name, style|
          ret << Repository::Export::CSS.mk_css_definitions("##{name}", style)
        end
        ret
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
