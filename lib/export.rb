#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  class Repository

    class ExportTree

      attr_reader :tlog, :timestamp, :written
      
      def initialize(tlog, params)
        @params = params
        @tlog, @params = tlog, params
        @timestamp = Time.new
        @__result__ = ''
        @written = false
      end

      def class_name
        self.class.to_s.split('::')[-2..-1].join('::')
      end
      
      def write
        raise "#{class_name}: need @file to write contents" unless @file
        raise "#{class_name}: need @__result__ to be set to write contents" unless @__result__
        
        wdir = tlog.repository.working_dir
        wdir.mkdir unless wdir.exist?
        file = wdir.join(@file)
        Info << " #{class_name}: writing #{@__result__.size} Bytes to #{file}"
        file.dirname.mkdir unless file.dirname.exist?
        p file
        file.open('w+'){ |f| f.write(@__result__)}
        @written = true
        @__result__
      end
      
    end
    
    # Parent to handle any way to export our Repository.
    #
    # To create a way to export a Repository there need to be a module
    # to extend the Repository instance (like Repository::Export::HTML)
    # and a module to extend each single instance of Posts, for example
    # Post::Export::HTML.
    #
    # The export class should respond on :to_s with the result stream.
    module Export

      # FIXME: use variables defined in config
      require 'lib/export/css.rb'
      require 'lib/export/html.rb'
      require 'lib/export/txt.rb'
      require 'lib/export/tags.rb'

      # Selects module +way+ and runs ::export
      def export(way, params = { })
        way = way.to_s.upcase
        cway = Repository::Export::const_get(way)
        @export =
          if cway
            Info << " Exporting via #{way}"
            cway.export(tlog, params)
          else
            raise "#{way} is unknown"
          end
      end

      def to_s
        @export.to_s
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
