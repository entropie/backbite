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
    post = @target.post(:test, :hash =>
                        { :topic => 'Hello from rspec',
                          :body  => 'foo',
                          :tags  => 'batz, bar, bumm'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  it "should list posts" do
    @target.posts.size.should == 1
    @target.posts do |po|
      po.class.should == Ackro::Post
      po.fields[:topic].value.should == "Hello from rspec"
      po.fields[:tags].value.should == "batz, bar, bumm"
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
