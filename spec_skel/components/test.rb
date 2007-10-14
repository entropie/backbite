#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define :test do

  style do
    margin_left 23.px
    color :red
  end

  fields do

    plugin_date do
      style do
        foo 'bar'
      end
    end

    input_topic do
      markup 'redcloth'
      before 'foo'
    end

    input_body do
      style do
        color 'red'
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
