#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Post do

  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end

  it "should accept a post via hash " do
    post = @target.post(:test, :hash =>
                        { :topic => 'Hello from rspec ahash',
                          :body  => 'foo ahash',
                          :tags  => 'batz, bar, bumm, ahash'
                        })
    post.save.should
    post.class.should == Backbite::Post::Ways::Hash
  end

  it "should accept a post via hash (20x)" do
    0.upto(5) do |i|
      post = @target.post(:test, :hash =>
                          { :topic => 'Hello from rspec ahash',
                            :body  => 'foo ahash',
                            :tags  => 'batz, bar, bumm, ahash'
                          })
      post.save.should
      post.class.should == Backbite::Post::Ways::Hash
    end
  end

  it "should accept a post via hash" do
    post = @target.post(:bar, :hash =>
                        { :topic => 'Hello from rspec ahash',
                          :body  => 'foo ahash',
                          :tags  => 'bar'
                        },
                        :meta  => { :date => Time.now-((3*24*60*60)+(23**5)) })
    post.save.should
    post.class.should == Backbite::Post::Ways::Hash
  end

  
  it "should accept a post via hash" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec nana',
                          :body  => 'foo nana',
                          :tags  => 'batz, bar, bumm, nana'
                        })
    post.save.should
    post.class.should == Backbite::Post::Ways::Hash
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
    post.class.should == Backbite::Post::Ways::File
  end

  it "should accept a post via hash to another component, metadate #0" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec another',
                          :body  => 'foo another',
                          :tags  => 'batz, bar, bumm, another',
                        },
                        :meta  => { :date => Time.now-(3*24*60*60), :author => 'me' })
    post.save.should
    post.class.should == Backbite::Post::Ways::Hash
  end
  it "should accept a post via hash to another component, metadate #1" do
    post = @target.post(:foo, :hash =>
                        { :topic => 'Hello from rspec keke',
                          :body  => 'foo keke',
                          :tags  => 'batz, bar, bumm, keke',
                        },
                        :meta  => { :date => Time.now-(10*24*60*60) })
    post.save.should
    post.class.should == Backbite::Post::Ways::Hash
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
