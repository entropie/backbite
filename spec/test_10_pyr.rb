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
      p(:deine => 'mama'){
        a :href => 'foo', :class => :foo
      }
      p{
        a :href => 'foo', :class => :foo
      }
      p{
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a("a", :href => 'foo', :class => :foo)
      }

      div {
        p{
          ul "la"
        }
      }
    }
  }
}


describe Backbite::Helper::Builder::Pyr do
  
  before(:each) do
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
    @std['/body/p'].size.should == 3
    @std['/body/div'].size.should == 1
    @std['/body/div/p'].size.should == 1
    @std['/body/div/p/ul/'].size.should == 1
    @std['/body/div/p/ul/'].first.value.should == "la"
    @std['/body/div/p/ul/'].first.parent.name.should == :p
    @std['/body/div/p/../'].name == :div
    @std['/body/']['/p'].size == 3
  end

  it "should be accessible via symbols" do
    @std['/body'][:p].size.should == 3
    @std['/body'][:div].size.should == 1
  end

  it "should respond to #children" do
    @std['/body/a/a'].children.size == 7
    @std['/body/a'].children.size == 3
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
    #@std['/body/div/p/ul'].path_length.should == 4
  end

  it "should be able to inner prepend elements (Elements)" do
    a=@std['/head'].prepend{ meta(:foo => :bar) { 'a' } }
    a.keys.map{ |a| a.name}.should == [:meta, :head]
  end
  it "should be able to inner append elements (Element)" do
    @std['/head'].first.append{ bar(:foo => :bar) { 'a' } }
    @std.keys.should == [:head, :body, :bar]
  end
  it "should be able to inner append/prepend multible elements (Element)" do
    @std['/head'].first.append{ bar(:foo => :bar) { 'a' } }
    @std.keys.should == [:head, :body, :bar]
    a=@std['/body'].prepend{ meta(:foo => :bar) { 'a' } }
    a.keys.map{ |a| a.name}.should == [:meta, :body]
  end
  it "should be able to append elements" do
    a = @std['/body'].append { meta(:foo => :bar) { 'a' } }
    @std['/body'].keys.map(&:name).should == [:body, :meta]
  end

  it "should respond to #to_s" do
    @std['/head'].to_s.strip.should == %(<head>
  <title>
    mytitle
  </title>
 </head>)
    @std['/body/div'].to_s.strip.should == "<div>\n   <p>\n    <ul>\n      la\n    </ul>\n   </p>\n  </div>"

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
