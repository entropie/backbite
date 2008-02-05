#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Backbite

  # Uses readline to get the field values
  class Post::Ways::Commandline < Post::Ways::Way
    def run(field, params)
      puts "#{"Predefined".red}: #{field.predefined.dump.white}" unless field.predefined.empty?
      result = Readline.readline('%20s > ' % field.to_sym.to_s.white)
      super(field, result)
    end
  end

  class Post::Ways::Shell < Post::Ways::Commandline
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
