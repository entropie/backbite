#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

define(:mercurial) do
  
  target :red

  style {
  }

  fields {

    plugin_permalink {
      style { float :right }
    }

    plugin_hg {
      tag :p
      style {
        color :blue
      }
    }

    input_author
    input_changeset
    
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
