#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Ackro::Tumblelog do

  before(:each) do
    @target = Ackro::Tumblelog.new(:rspec, $default_config)
    @target.repository.setup!
  end

  it "should respond non nil on various attributes" do
    [:repository, :config, :name, :root, :author, :url].each do |attr|
      @target.send(attr).should
    end
  end

  it "should accept a post via array" do
    post = @target.post(:test, :array => ['Hello from rspec', 'foo'])
    ps = post.save
    ps.should    
    post.class.should == Ackro::Post::Ways::Array
  end

  it "should list posts" do
    posts = @target.posts
    pp posts #.class
    #posts.class.should == Ackro::Components::Component
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
