#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include Ackro

describe Config do

  before(:each) do
    @config = Ackro::Config.read($default_config)
  end
  
  it "should parse the config string to a hash" do
    @config.should
    @config.class.should == Hash
  end

  it "should take care of the order of inserting" do
    @config.sort.first.first.should == :defaults
    @config.sort.last.first.should  == :html
    @config[:html].sort.first.first.should == :body
  end

  it "should replace values of the hash" do
    @config.with_replacer[:defaults][:title].
      should == "rspec - foobar title"
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
