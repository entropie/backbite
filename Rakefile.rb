#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'lib/ackro.rb'

task :spec do
  ENV['DEBUG'] = '1'
  sh 'spec spec -r spec/default_config'
end

task :specdoc => [:spechtml] do
  ENV['DEBUG'] = '1'
  sh 'spec spec -d --format specdoc -r spec/default_config -r lib/ackro.rb'
end

task :spechtml do
  system("touch #{file = "/home/mit/public_html/doc/ackro.suc/spec.html"}")
  system "spec spec -f h:#{file} -r spec/default_config"
end

task :rdoc do
  system('rm ~/public_html/doc/ackro.suc/rdoc -rf')
  system('rdoc -T rubyavailable -a -I png -S -m Ackro -o ~/public_html/doc/ackro.suc/rdoc -x "spec"')
end

task :console do
  puts "You may want to to @a an ready to use tumblog object"
  ENV['DEBUG'] = '1'
  system("irb -r spec/default_config.rb")
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
