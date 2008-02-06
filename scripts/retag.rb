#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../lib/backbite'
require 'readline'
require 'yaml'

tlog = ARGV.shift or raise "need target tumblog"

tlog = Backbite.register[tlog.to_sym]

ap = tlog.posts + tlog.archive

$stdout.sync = true

t = Pathname.new('/home/mit/N')

ap.each do |post|
  f = YAML::load(post.file.readlines.to_s)
  puts post
  puts ("-"*60).white
  tags = Readline.readline('>')
  tags = tags.split(' ')
  if tags and not tags.empty?
    f[:plugin_tags].push(*tags)
    File.open(post.file.to_s, 'w+'){ |fl| fl.write(YAML::dump(f))}
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
