#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Posts do
  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end
  
  it "should have a corresponding size" do
    @target.posts.size.should == 12
  end

  it "should list a specific post (==, =~)" do
    @target.posts.find{ |p| p.topic == 'Hello from rspec another' }.
      size.should == 1
    @target.posts.find{ |p| p.body =~ /^foo another$/ }.
      size.should == 1
  end

  it "should list specific posts (:target)" do
    @target.posts.find{ |p| p.config[:target] == :black }.
      size.should == 9
    @target.posts.find{ |p| p.config[:target] == :red }.
      size.should == 3
  end

  
  it "should list a specific post (:between) " do
    @target.posts.filter(:between => 4.days..3.days).size.should == 1
    @target.posts.filter(:between => 11.days..9.days).size.should == 1
  end

  it "should list a specific post (:tags) " do
    @target.posts.filter(:tags => %w(batz)).size.should == 11
    @target.posts.filter(:tags => %w(another)).size.should == 1
    @target.posts.filter(:tags => %w(ahash another)).size.should == 8
  end

  
  it "should list posts" do
    @target.posts do |po|
      po.class.should == Backbite::Post
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
