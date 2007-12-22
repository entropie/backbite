#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :content

  style {
    border_left "3px solid #205F21"
    background_image 'url(../images/l_bg.png)'    
    margin_bottom 23.px
    padding_left 10.px
    float :left
    min_width "45%"
  }

  fields {
    plugin_permalink {
      style {
        float :right
        background_color :transparent
        color :yellow
        font_size 10.px
      }
    }

    plugin_changeset {
      style {
        float :left        
        padding_right 20.px
      }
    }
    
    plugin_author {
      style {

      }
    }
    
    input_hg {
      tag :p
      style {
        color '#28902A'
        font_family 'arial'
        padding 10.px
        margin 0.px
      }
    }

    plugin_tags {
      value " mercurial, automated "
    }

    plugin_date {
      style {
        margin_left 0.px
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
