#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../lib/backbite'
require 'readline'


tlog = Backbite.register[:polis]

Dir['/home/mit/Data/pb/spool/**.yaml'].grep(/r\.yaml/).map do |y|
  YAML::load(File.open(y).readlines.join)
end.sort_by{ |p| p[:date] }.reverse.each do |pst|
  tags = Readline.readline("Tags for #{pst[:topic]} ")
  tags << " imported"
  thash = {
    :topic => pst[:topic],
    :body  => pst[:body],
    :tags => tags
  }
  tlog.post(:blog,
            :hash => thash,
            :meta => { :date => Time.at(pst[:date].to_i)}
            ).save
  
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
