#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  class Post::Ways::File < Post::Ways::Way
    def run(field, params)
      result = params[:file].
        scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/m).
        flatten.join
      super(field, result)
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
