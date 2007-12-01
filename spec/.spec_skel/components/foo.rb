#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define :foo do

  target :red
  
  style do
    color :navy
    border_left '2px solid blue;'
    padding_left 10.px
    margin_bottom 20.px
  end

  fields do

    plugin_date do
      style do
        color '#BF7F17'
        float :right
        padding 8.px
        right 0.px
      end
    end

    
    input_topic do
      markup 'redcloth'
      before 'foo'
      tag    :h1
      style do
        color :blue
        font_size '20px'
        background_color '#E79E27'
        padding 5.px
        margin 0.px
        margin_bottom 0.px
        z_index 10
      end
    end

    input_body do
      style do
        background_color '#A6BED7'
        padding 15.px
      end
    end

    plugin_tags do
      style do
        color 'grey'
        background_color '#A6BED7'
        text_align :right
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
