#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

target = Ackro::Tumblelog.new(:rspec, $default_config)
target.repository.setup!


describe Ackro::Repository::Export do
  it "" do
    puts
    puts target.repository.export(:html)
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
