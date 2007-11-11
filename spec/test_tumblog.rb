#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Ackro::Tumblelog do

  before(:each) do
    @target = Ackro::Tumblelog.new(:rspec, $default_config)
    @target.repository.setup!
  end

  it "should respond with non nil on various attributes" do
    [:repository, :config, :name, :root, :author, :url].each do |attr|
      @target.send(attr).should
    end
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
