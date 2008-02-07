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
        
        InputException = Backbite::NastyDream(self)
        
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

          unless field.predefined.empty?
            Info << " - #{self.class}.#{field.to_sym}:merge_predef:#{field.predefined.dump}"
            value << field.predefined
          end
          
          value
        end
        
        def inspect
          "<Way::#{self.class.name.to_s.capitalize} Values:(#{@result.values.to_a.join(', ')})>"
        end

        def metadata
          @metadata ||= Post::Metadata.new(@meta,
                                           :component => component,
                                           :way => self.class.to_s)
        end

        def src
          @src ||= YAML::load(file.readlines.join)
        end

        alias :__source__ :src
        
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
        rescue
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

      require 'backbite/ways/hash'
      require 'backbite/ways/yaml'
      require 'backbite/ways/file'
      require 'backbite/ways/mail'
      require 'backbite/ways/editor'
      require 'backbite/ways/commandline'
      
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
