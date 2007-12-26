#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :box

  style {
    #background_image 'url(../images/l_bg.png)'
    position :relative
    padding_left 50.px
    padding_right 40.px
  }

  fields {

    plugin_changeset {
      style {
        float :left
        padding_right 20.px
      }
    }

    plugin_tags {
      value " mercurial, automated "
      style {
        background_color :transparent
      }
    }

    
    plugin_author    
    input_hg {
      tag :p
      style {
        padding_left 20.px
        color '#615B57'
        margin 0.px
        font_family 'helvecita'
      }
    }

    plugin_date {
      style {
        display :none
      }
    }

    plugin_permalink {
      style {
        background_color :transparent
        left 15.px
        # margin_right -23.px
        # margin_top -10.px
        #display :block
      }
    }

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
