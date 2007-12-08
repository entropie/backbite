#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

%w(fixnum symbol string).each do |l|
  require "backbite/ruby_ext/" + l.to_s
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
