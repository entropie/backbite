#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../lib/backbite'
require 'readline'

tlog = ARGV.shift or raise "need target tumblog"

tlog = Backbite.register[tlog.to_sym]

ap = tlog.posts + tlog.archive

datss = Hash[*ap.map{ |p| [p.date,p] }.flatten]
datss.each_pair do |date, post|
  pss = ap.select{ |p| p.date == date}
  save = pss.shift
  pss.each do |post|
    print "."
    post.remove!
  end
end

puts

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
