#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

Target = Ackro::Tumblelog.new(:rspec, $default_config)
Target.repository.setup!

describe Ackro::Post do
  before(:each) do
    @target = Target
  end

  it "should accept a post via hash" do
    post = @target.post(:test, :hash =>
                        { :topic => 'Hello from rspec ahash',
                          :body  => 'foo ahash',
                          :tags  => 'batz, bar, bumm ahash'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  it "should accept a post via file" do
    str = {
      :topic => 'Hello from rspec file',
      :body =>  'foo file',
      :tags =>  'batz, bar, bumm file'
    }
    str = str.map{ |c, v| "[%s_start]%s[%s_end]" % [c,v,c]}
    post = @target.post(:test, :way => :file, :string => str.join)
    post.save.should
    post.class.should == Ackro::Post::Ways::File
  end

  it "should accept a post via hash to another component" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec ahash',
                          :body  => 'foo ahash',
                          :tags  => 'batz, bar, bumm ahash'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  it "should have a corresponding size" do
    @target.posts.size.should == 3
  end
  
  it "should list posts" do
    @target.posts do |po|
      po.class.should == Ackro::Post
      po.fields[:topic].value.should =~ /^Hello from rspec/
      po.fields[:tags].value.should =~ /^batz, bar, bumm/
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
