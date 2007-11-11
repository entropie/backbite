#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Ackro::Post do
  before(:each) do
    @target = Ackro::Tumblelog.new(:rspec, $default_config)
    @target.repository.setup!
  end

  it "should accept a post via array" do
    post = @target.post(:test, :array => ['Hello from rspec', 'foo'])
    post.save.should
    post.class.should == Ackro::Post::Ways::Array
  end

  it "should list posts" do
    @target.posts.size.should == 1
    @target.posts do |po|
      po.class.should == Ackro::Post
      po.fields.first.value.should == "Hello from rspec"
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
