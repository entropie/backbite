#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'lib/ackro.rb'

task :spec do
  ENV['DEBUG'] = '1'
  sh 'spec spec -r spec/default_config -r lib/ackro.rb'
end

task :specdoc => [:spechtml] do
  ENV['DEBUG'] = '1'
  sh 'spec spec -d --format specdoc -r spec/default_config -r lib/ackro.rb'
end

task :spechtml do
  system("touch #{file = "/home/mit/public_html/doc/ackro.suc/spec.html"}")
  system "spec spec -f h:#{file} -r spec/default_config -r lib/ackro.rb"
end

task :rdoc do
  system('rm ~/public_html/doc/ackro.suc/rdoc -rf')
  system('rdoc -T rubyavailable -a -I gif -S -m Ackro -o ~/public_html/doc/ackro.suc/rdoc -x "spec"')
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
