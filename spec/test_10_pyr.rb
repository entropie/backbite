#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

default = proc{
  html {
    head {
      title 'mytitle'
    }
    body {
      ap{
        a :href => 'foo', :class => :foo
      }
      ap{
        a :href => 'foo', :class => :foo
      }
      ap{
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
      }

      div {
        ap{
          ul "la"
        }
      }
    }
  }
}


describe Backbite::Helper::Builder::Pyr do
  
  before(:all) do
    @target = Backbite::Helper::Builder::Pyr
    @std = @target.new.build(&default)
  end

  it "should be able to build a structure" do
    @std.should
  end
  
  it "should be able to build a structure" do
    @std.kind_of?(Backbite::Helper::Builder::Pyr::Element).should
  end
  
  it "should have accessible keys via /path" do
    @std['/body/ap'].size.should == 3
    @std['/body/div'].size.should == 1
    @std['/body/div/ap'].size.should == 1
    @std['/body/div/ap/ul/'].size.should == 1
    @std['/body/div/ap/ul/'].first.value.should == "la"
    @std['/body/div/ap/ul/'].first.parent.name.should == :ap
    @std['/body/div/ap/../'].name == :div
    @std['/body/']['/ap'].size == 3
  end

  it "should be accessible via symbols" do
    @std['/body'][:ap].size.should == 3
    @std['/body'][:div].size.should == 1
  end

  it "should respond to #children" do
    @std['/body/ap/a'].children.size == 7
    @std['/body/ap'].children.size == 3
    @std['/head'].children.size == 1
  end

  it "should respond on #parent" do
    @std['/head/title'].first.parent.name.should == :head
  end

  it "should able to recive new content" do
    @std['/head/title'].value = 23
    @std['/head/title'].value.should == "23"
  end
  
  it "should have a path length" do
    @std.first.path_length.should == 1
    @std['/head/title'].first.path_length.should == 2
    @std['/body/div/ap/ul/'].path_length.should == 4
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
