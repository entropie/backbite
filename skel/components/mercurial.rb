#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :red

  style {
    border "1px solid navy"
    margin_bottom 10.px
    padding_left 10.px
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
        color :silver
        background_color '#6F6F6F'
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
