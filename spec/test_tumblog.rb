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
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
