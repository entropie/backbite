#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :box

  style {
    #background_image 'url(../images/l_bg.png)'    
    padding_left 30.px
    padding_right 30.px
  }

  fields {
    plugin_permalink {
      style {
        float :right
        background_color :transparent
        font_size 20.px
        margin_right -23.px
        margin_top -10.px
      }
    }

    plugin_changeset {
      style {
        float :left        
        padding_right 20.px
      }
    }
    
    plugin_author    
    input_hg {
      tag :p
      style {
        padding_left 20.px
        color '#615B57'
        margin 0.px
        font_family 'fixed'
      }
    }

    plugin_tags {
      value " mercurial, automated "
    }

    plugin_date
  }

end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
