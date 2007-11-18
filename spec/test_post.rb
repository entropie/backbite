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
                          :tags  => 'batz, bar, bumm, ahash'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  it "should accept a post via hash" do
    post = @target.post(:bar, :hash =>
                        { :topic => 'Hello from rspec ahash',
                          :body  => 'foo ahash',
                          :tags  => 'bar'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  
  it "should accept a post via hash" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec nana',
                          :body  => 'foo nana',
                          :tags  => 'batz, bar, bumm, nana'
                        })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  
  it "should accept a post via file" do
    str = {
      :topic => 'Hello from rspec file',
      :body =>  'foo file',
      :tags =>  'batz, bar, bumm, file'
    }
    str = str.map{ |c, v| "[%s_start]%s[%s_end]" % [c,v,c]}
    post = @target.post(:test, :way => :file, :file => str.join)
    post.save.should
    post.class.should == Ackro::Post::Ways::File
  end

  it "should accept a post via hash to another component, metadate #0" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec another',
                          :body  => 'foo another',
                          :tags  => 'batz, bar, bumm, another',
                        },
                        :meta  => { :date => Time.now-(3*24*60*60) })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end
  it "should accept a post via hash to another component, metadate #1" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec keke',
                          :body  => 'foo keke',
                          :tags  => 'batz, bar, bumm, keke',
                        },
                        :meta  => { :date => Time.now-(10*24*60*60) })
    post.save.should
    post.class.should == Ackro::Post::Ways::Hash
  end

  
end

describe Ackro::Posts do

  it "should have a corresponding size" do
    Target.posts.size.should == 6
  end

  it "should list a specific post (==, =~)" do
    Target.posts.find{ |p| p.topic == 'Hello from rspec another' }.
      size.should == 1
    Target.posts.find{ |p| p.body =~ /^foo another$/ }.
      size.should == 1
  end

  it "should list specific posts (:target)" do
    Target.posts.find{ |p| p.config[:target] == :black }.
      size.should == 3
    Target.posts.find{ |p| p.config[:target] == :red }.
      size.should == 3
  end

  
  it "should list a specific post (:between) " do
    Target.posts.filter(:between => 4.days..3.days).size.should == 1
    Target.posts.filter(:between => 11.days..9.days).size.should == 1
  end

  it "should list a specific post (:tags) " do
    Target.posts.filter(:tags => %w(batz)).size.should == 5
    Target.posts.filter(:tags => %w(another)).size.should == 1
    Target.posts.filter(:tags => %w(ahash another)).size.should == 2
  end

  
  it "should list posts" do
    Target.posts do |po|
      po.class.should == Ackro::Post
      po.fields[:topic].value.should =~ /^Hello from rspec/
      po.fields[:tags].value[0..-2].should == ["batz", "bar", "bumm"] if po.component.name != :bar
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
