#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Repository

    class ExportTree

      attr_reader :tlog, :timestamp, :written
      
      def initialize(tlog, params)
        @tlog, @params = tlog, params.dup
        @timestamp = Time.new
        @__result__ = ''
        @written = false
      end

      def class_name
        self.class.to_s.split('::')[-2..-1].join('::')
      end

      def written?
        @written
      end
      
      def write
        raise "#{class_name}: need @file to write contents" unless @file
        raise "#{class_name}: need @__result__ to be set to write contents" unless @__result__
        wdir = tlog.repository.working_dir
        wdir.mkdir unless wdir.exist?
        file = wdir.join(@file)
        Info << "#{"%-15s" % class_name} #{"%10i" % @__result__.size} Bytes to #{file}"
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

      module ExportNames # :nodoc: All
        def to_s
          name.to_s.split('::').last
        end
      end
      
      UnknownWay = Backbite::NastyDream(self)

      def Export.ways
        Repository::Export.constants.map{ |c|
          next unless c == c.upcase
          self.const_get(c).extend(ExportNames)
        }.compact
      end

      def ways
        __require__
        Export.ways
      end
      
      # require every ./export/*.rb file in the repos
      def __require__
        unless self.class.const_defined?(:REQUIRED)
          (path = join('export')).entries.grep(/[^\.]/).each do |wfile|
            file = path.join(wfile)
            Debug << "Export: loading #{file}"
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
      def export(way = nil, params = { })
        __require__
        ret = nil
        return self unless way
        raise UnknownWay, way unless Repository::Export.known?(way)
        cway = Repository::Export::choose(way)
        @export =
          if cway
            Debug << "Exporting via #{way}"
            ret = cway.export(tlog, params)
            if ret.respond_to?(:clean!)
              Info << "#{way.to_s.upcase}: cleaning ./tmp"
              ret.clean!(tlog, params)
            end
          else
            Warn << "#{way} is unknown"
          end
        move!
        ret
      end

      
      def move!
        Info << "copy working dir to repository"
        system("cp -r #{working_dir}/* #{join('htdocs')}/")
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
