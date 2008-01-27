#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require '../lib/backbite'

Backbite::Contrib.all.each_pair do |name, value|
  Dir.chdir(Backbite::Contrib.path_of(name).to_s) do
    print Dir.pwd, ": "
    puts s="hg pull"
    puts `#{s}`
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
