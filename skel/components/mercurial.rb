#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :box

  style {
    position :relative
    backround_color :red
    padding 0.px
    margin 0.px
  }

  fields {

    plugin_changeset {
      style {
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
        margin_right -23.px
        # margin_top -10.px
        display :block
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
