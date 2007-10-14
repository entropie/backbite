#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Date < Plugin

  def content
    Time.now
  end

  #  filter         - filter applied for every output module

  #  html_filter    - specific filter for output module

  ## Following keywords are evaluated before the components writes the
  ## output
  
  #  before         - content_before

  #  content        - content

  #  after          - content_after

end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
