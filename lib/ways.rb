#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  # Responsible for re-mapping the fields, calling plugin stuff and
  # saving the nut in the right place.
  #
  # Post delegates the Component instance.
  class Post < Delegator

    module Ways

      # Dispatch selects +way+ and returns proper instance to operate
      # on in a block.
      def self.dispatch(way) # :yield: Way.new
        ret = nil
        if const = const_get(way.to_s.capitalize)
          ret = const.new
          yield ret
        else
          raise "Sorry, way '#{way}' is unknown."
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

        def run(field, value)
          Info << " - #{self.class}.#{field.to_sym}='#{value}'"
          value
        end
        
        def inspect
          "<Way::#{self.class.name.to_s.capitalize} Values:(#{@result.values.to_a.join(', ')})>"
        end
        
        # Parses the fields hash, and decides which Post class is
        # qualified to handle the field.
        #
        # If the field's a plugin, we're going to create an instance of
        # it (because we only want to work on a single plugin instance).
        def process(params, component)
          Info << " #{component.name} -> #{self.class}.proccess"
          @component = component
          fields.each do |hand|
            @result[hand.name.to_sym] =
              if hand.is_a?(:field)
                value = run(hand, params)
                hand.run( value, params, tlog )
              elsif hand.is_a?(:plugin)
                # create plugin instance
                plugin = hand.run(params, tlog)
                plugin.dispatch(self)
                plugin.prepare
                plugin
              end
          end
          #@result
          self
        end

        def filename
          @filename ||= "#{ @component.name }-#{(t=Time.now).to_i}-#{t.usec}.yaml"
        end
        
        def save(how = :to_yaml)
          file = @tlog.repository.join('spool').join(filename)
          contents = send(how)
          Info << " #{component.name}: write #{how}(#{contents.size}Bytes) to #{file}"
          file.open('w+') do |file|
            file.write(contents)
          end
          Info << "#{component.name} Finished"
          true
        end
        
        def to_yaml
          result = ::Hash[*@result.map{ |h,k| [h,k.value] }.flatten]
          result[:metadata] =
            Post::Metadata.new(:component => @component.name,
                               :way => self.class.to_s)
          result.to_yaml
        end
        private :to_yaml

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

        # Reformats to be a valid Post instance.
        def process
          meta = source.delete(:metadata)
          @component = tlog.components[meta[:component]].
            extend(Components::YAMLComponent)
          @component.map(source)
          @component.to_post
        end
        
        def run(field, params); raise "no need to run a yaml Way"; end

        def save(*args); raise "cannot save a yaml instance"; end
        
      end
      
      class File < Way
        def run(field, params)
          result = params[:string].
            scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/).
            flatten.join
          super(field, result)
        end
      end

      class Commandline < Way
        def run(field, params)
          result = Readline.readline(' %20s>' % field.name.to_s)
          super(field, result)
        end
      end

      class Editor < Way
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
