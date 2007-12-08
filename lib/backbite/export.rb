#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Repository

    class ExportTree

      attr_reader :tlog, :timestamp, :written
      
      def initialize(tlog, params)
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

      UnknownWay = Backbite::NastyDream(Export)
      
      # require every ./export/*.rb file in the repos
      def __require__
        unless self.class.const_defined?(:REQUIRED)
          (path = join('export')).entries.grep(/[^\.]/).each do |wfile|
            file = path.join(wfile)
            Info << "Export: loading #{file}"
            require(file)
          end
          self.class.const_set(:REQUIRED, true)
        end
        true
      end

      def self.known?(way)
        const_defined?(way.to_s.upcase)
      end

      def self.choose(way)
        const_get(way.to_s.upcase)
      end
      
      # Selects module +way+ and runs ::export
      def export(way, params = { })
        __require__ 
        raise UnknownWay, way unless Repository::Export.known?(way)
        cway = Repository::Export::choose(way)
        @export =
          if cway
            Info << " Exporting via #{way}"
            cway.export(tlog, params)
          else
            Warn << "#{way} is unknown"
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
