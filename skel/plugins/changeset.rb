#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Changeset < Plugin          

  HG_URL = 'http://ackro.ath.cx/~mit/hg/%s/'
  
  def input; end

  def html_filter
    name, rev, chs = field.value.split(':')

    %Q(<a class="url" href="#{HG_URL % name}">#{name}</a>:<a href="#{(HG_URL % name) << chs}">#{rev}</a>)
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
