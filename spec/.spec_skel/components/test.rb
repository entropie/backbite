#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define :test do

  target :black

  style do
    margin_left '48%'
    margin_bottom 20.px    
    border_top '20px solid yellow'
    color '#FFD700'
    border_left '3px solid yellow'
    border_bottom '3px solid yellow'
    border_right '3px solid yellow'
    padding_left 10.px
  end

  fields do
  
    input_topic do
      tag 'h1'
      markup 'redcloth'
    end

    input_body do
      style do
        color '#fab444'
        font_family 'verdana'
        font_size 18.px
        padding_bottom 20.px
        margin_bottom 10.px
      end
    end

    plugin_tags do #optional
      style do
        color 'silver'
        text_align :left
        float :left
        padding 3.px        
      end
    end

    plugin_date do # optional
      style do
        background_color '#3076C8'
        color            '#0F59B8'
        padding 3.px
        text_align :right
        margin_left -10.px
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
