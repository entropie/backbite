#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Responsible for re-mapping the fields, calling plugin stuff and
  # saving the nut in the right place.
  #
  # Post delegates the Component instance.
  class Post < Delegator

    UnknownWay = Backbite::NastyDream(self)
    
    module Ways

      def self.ways
        constants.map{ |c|
          next if c == 'Way'
          const_get(c)
        }.compact
      end

      def ways
        Ways.ways
      end
      
      def way?(w)
        Ways.way?(w)
      end

      def self.way?(w)
        const_defined?(w.to_s.capitalize)
      end

      def select_way_with_abbrev(target)
        abbw = ways.map{ |w| w.to_s.split('::').last.downcase }.abbrev
        abbw[target]
      end
      
      # Dispatch selects +way+ and returns proper instance to operate
      # on in a block.
      def self.dispatch(way) # :yield: Way.new
        way, ret = way.to_s.capitalize, nil
        if const_defined?(way) and const = const_get(way)
          ret = const.new
          yield ret
        else
          raise UnknownWay, way
        end
        return ret
      end


      # Parent class for any old way to post to a tumblog.
      class Way

        attr_accessor :fields
        
        attr_accessor :tlog

        attr_reader   :result
        
        attr_reader   :component
        
        def initialize
          @result = { }
        end

        # Should be called via +super+ in the child.
        def run(field, value)
          Info << " - #{self.class}.#{field.to_sym}='#{value}'"
          value
        end
        
        def inspect
          "<Way::#{self.class.name.to_s.capitalize} Values:(#{@result.values.to_a.join(', ')})>"
        end

        def metadata
          @metadata ||= Post::Metadata.new(@meta,
                                           :component => component.name,
                                           :way => self.class.to_s)
        end
        
        # Parses the fields hash, and processes any field according to
        # its class.
        #
        # If the field's a plugin, we're going to create an instance of
        # it (because we only want to work on a single plugin instance).
        def process(params, component)
          Info << "#{component.name.to_s.upcase} -> #{self.class}"
          @component = component.dup
          @meta = params[:meta]
          fields.each do |hand|
            @result[hand.name.to_sym] =
              if hand.is_a?(:field)
                value = run(hand, params)
                hand.run( value, params, tlog )
              elsif hand.is_a?(:plugin)
                # create plugin instance
                field = hand.run(params, tlog)
                field.plugin.dispatch(field, self)
                field.plugin.prepare
                field.plugin
              end
          end
          self
        end
        
        # the filename we'll write the result or where the result is
        # stored, depending on the state.
        def filename
          @filename ||= "#{ @component.name }-#{(t=Time.now).to_i}-#{t.usec}.yaml"
        end
        
        # Saves the result in +filename+ with method +how+, +to_yaml+
        # is the only implemented method to save a nut yet.
        def save(how = :to_yaml)
          file = @tlog.repository.join('spool').join(filename)
          contents = send(how)
          Info << "#{component.name}: write #{how}(#{contents.size}Bytes) to #{file}"
          file.open('w+') do |file|
            file.write(contents)
          end
          contents.size
        end

        def to_s
          self.class.to_s.split('::').last
        end
        
        # Save the nut the YAML way.
        def to_yaml
          result = { }
          @result.each{ |nam, infi|
            value = infi.value
            value = value.shift if value.kind_of?(Array) and value.size == 1
            result[nam] = value
          }
          result[:metadata] = metadata
          result.to_yaml
        end
        private :to_yaml

        # the name of the way.
        def self.name
          self.to_s.split('::').last.downcase.to_sym
        end
        
      end

      class Hash < Way
        
        def run(field, params)
          result = params[:hash][field.to_sym]
          super(field, result)
        end
      end


      # Yaml is the way to retrive Posts from already saved yaml files.
      class Yaml < Way
        
        attr_accessor :source

        def metadata
          source[:metadata]
        end
        
        # Reformats to be a valid Post instance.
        def process
          @component = tlog.components[metadata[:component]].
            extend(Components::YAMLComponent)
          @component.map(source)
          @component.metadata = metadata
          @component.to_post
        end
        
        def run(field, params); raise "no need to run a YAML Way"; end

        def save(*args); raise "cannot save a YAML instance"; end
        
      end
      

      class File < Way
        
        def run(field, params)
          result = params[:file].
            scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/m).
            flatten.join
          super(field, result)
        end
      end


      class Editor < Way
        
        def tfilename
          tlog.repository.join("tmp", filename.to_s+'.tmp')
        end

        def header
          "foo bar batz\n\n"
        end

        def mkfield(field)
          ret = ''
          ret <<
            if field.interactive? 
              "# #{field.plugin.input}\n"
            else
              ''
            end
            ret << "[#{field.to_sym}_start]\n\n[#{field.to_sym}_end]\n"
            ret
        end
        
        def fileskel(comp)
          file = header
          comp.fields.each do |field|
            unless field.interactive?
              file << mkfield(field) << "\n\n"
            end
          end
          file
        end

        def yes_no?(text = 'Done? %s/%s', y = 'Y', n = 'n', &blk)
          loop {
            ret = blk.call
            r = Readline.readline((text.to_s + " ") % [y,n]).strip
            r = y if r.empty?
            false
            return ret if r =~ /^#{y}/i
          }
        end

        def edit!
          system("%s '%s'" % [tlog.config[:defaults][:editor], tfilename])
          ::File.open(tfilename.to_s).readlines.to_s
        end

        def process(params, comp)
          @component = comp
          tfilename.open('w+'){ |res| res.write(@fcontents = fileskel(component)) }
          @fcontents = yes_no?{
            edit!
          }
          super
          self
        end

        def run(field, params)
          result = @fcontents.scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/m).
            flatten.join.strip
          super(field, result)
        end
      end

      
      # Uses readline to get the field values
      class Commandline < Way
        def run(field, params)
          result = Readline.readline('%20s > ' % field.to_sym.to_s.white)
          super(field, result)
        end
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
