#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include Ackro

describe Configurations do

  it "it should parse the config string to a hash" do
    config = Ackro::Configurations.read($default_config)
    config.should
    config.ordered.first.first.should == :defaults
    config.ordered.last.first.should  == :html
    config[:html].ordered.first.first.should == :body
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
