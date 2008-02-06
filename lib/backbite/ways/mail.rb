#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Backbite
  class Post::Ways::Pipe < Post::Ways::Way
    def src
      ARGV.clear
      @src ||= ARGF.readlines.to_s
    end
    
    def run(field, params)
      Backbite[:colors] = false
      result = src.scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/m).
        flatten.join
      super(field, result.strip)
    end
  end

  class Post::Ways::Mail < Post::Ways::Pipe
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
