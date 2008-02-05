#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  class Post::Ways::Hash < Post::Ways::Way

    def run(field, params)
      unless params[:hash] or params[:hash][field.to_sym]
        raise InputException, "invalid input dataset; you posted by #{self}"
      end
      result = params[:hash][field.to_sym]
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
