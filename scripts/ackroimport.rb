#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../lib/backbite'#
require 'readline'


tlog = Backbite.register[:polis]

dirs = Dir['/home/mit/Data/Ackro/spool/**.yaml'] +
  Dir['/home/mit/Data/Ackro/htdocs/static/**/spool/**.yaml']


a=dirs.grep(/\.yaml/).map do |y|
  co = y[/(\w+)\.yaml$/, 1].to_sym
  [co,YAML::load(File.open(y).readlines.join)]
end.uniq

a.each do |name, cont|
  c = cont
  case name
  when :shorto
    name = :nut
  when :twoimages
    name = :multipleimg
    a = cont.delete(:secimg)
    b = cont.delete(:lightbox)
    cont.merge!(:multipleimg => "#{a}\n#{b}")
  when :ruby, :shell, :wise, :irc, :btw
    next
  end
  # puts
  # pp cont
  tags = ''
  #tags = Readline.readline("Tags for #{name} ")
  tags << "imported"
  d = Time.at(cont.delete(:date).to_i)
  cont.merge!(:tags => tags)
  post = tlog.post(name,
            :hash => cont,
            :meta => { :date => d}
                   )
  #unless Readline.readline('Y/n: ') =~ /[nN]/
  post.save
  #end
  
end

# illusion  science fiction


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
