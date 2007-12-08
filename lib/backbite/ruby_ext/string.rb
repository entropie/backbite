#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

# http://source.ramaze.net/#/lib/ramaze/snippets/string/color.rb
class String
    {
      :reset          =>  0,
      :bold           =>  1,
      :dark           =>  2,
      :underline      =>  4,
      :blink          =>  5,
      :negative       =>  7,
      :black          => 30,
      :red            => 31,
      :green          => 32,
      :yellow         => 33,
      :blue           => 34,
      :magenta        => 35,
      :cyan           => 36,
      :white          => 37,
  }.each do |key, value|
    if Backbite.globals.colors?
      define_method key do
        "\e[#{value}m" + self + "\e[0m"
      end
    else
      define_method key do
        self
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
