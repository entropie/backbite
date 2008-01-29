#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Posts::Filter do

  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end
  
  it "should list specific posts (:target)" do
    @target.posts.filter(:target => :black).size.should == 9
    @target.posts.filter(:target => :red).size.should == 3
  end

  it "target by ids" do
    @target.posts.filter(:ids => [1,2,3]).size.should == 3
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
  
end

describe Backbite::Posts do
  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end
  
  it "should have a corresponding size" do
    @target.posts.size.should == 12
  end

  it "should archive posts" do
    @target.posts.archive!
  end

  it "should have archived posts" do
    @target.posts.size.should == 7
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
