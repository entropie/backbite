#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define :foo do

  style do
    margin_right 23.px
    color :black
  end

  fields do

    plugin_date do # optional
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
