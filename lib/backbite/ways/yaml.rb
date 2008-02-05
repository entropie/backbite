#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  # Yaml is the way to retrive Posts from already saved yaml files.
  class Post::Ways::Yaml < Post::Ways::Way
    
    attr_accessor :source
    attr_accessor :file
    
    def metadata
      source[:metadata]
    end
    
    # Reformats to be a valid Post instance.
    def process
      @component = tlog.components[metadata[:component]].
        extend(Components::YAMLComponent)
      @component.map(source)
      @component.metadata = metadata
      post = @component.to_post
      post.file = self.file
      post
    end
    
    def run(field, params); raise "no need to run a YAML Way"; end

    def save(*args); raise "cannot save a YAML instance"; end
    
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
