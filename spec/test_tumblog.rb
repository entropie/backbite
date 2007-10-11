#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Ackro::Tumblelog do

  before(:each) do
    @target = Ackro::Tumblelog
  end

  it "should respond to some stuff" do
    @target.new(:rspec, $default_config)
  end

  it "should accept a post" do
    p @target.new(:rspec, $default_config).
      post(:blog, :array => ['foo', 'bar'])
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