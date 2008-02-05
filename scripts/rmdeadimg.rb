#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../lib/backbite'
require 'readline'
require 'open-uri'
require 'RMagick'

tlog = ARGV.shift or raise "need target tumblog"

tlog = Backbite.register[tlog.to_sym]

ap = tlog.posts + tlog.archive

$stdout.sync = true

ap.each do |post|
  case post.name
  when :img, :lightbox, :multipleimg
    f = if post.fields.include?(:lightbox)
          post.fields[:lightbox]
        else
          post.fields[:multipleimg]
        end.value
    f = [f] unless f.kind_of?(Array)
    f.each do |nf|
      begin
        Magick::Image::read(nf).first.columns
        print "."
      rescue OpenURI::HTTPError, Errno::ENOENT, Magick::ImageMagickError
        print "!"
        begin
          post.remove!
        rescue
          p $!
        end
      end
    end
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
