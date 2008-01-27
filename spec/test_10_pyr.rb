#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include Backbite::Helper::Builder

simple = proc {
  b{ s "23"}
  foo {
    asd "23"
    baz "fo"
  }
}


multible = proc {
  div "234"
  div {
    p "lala"
    p "lulu"
  }
}

default = proc {
  html {
    head {
      title 'mytitle'
    }
    body {
      div(:deine => 'mama'){
        a :href => 'foo', :class => :foo
      }
      div{
        a :href => 'foo', :class => :foo
      }
      div{
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a :href => 'foo', :class => :foo
        a("a", :href => 'foo', :class => :foo)
      }

      div {
        div{
          ul {
            li "la"
            li "lu"
          }
        }
      }
    }
  }
}


def nospaces(str, ostr)
  str.gsub(/\s/, '').should == ostr.gsub(/\s/, '')
end

def mkchildren(t, n, i)
  r = t.new(n)
  0.upto(i-1) do |i|
    r.inner_append(t.new(n))
  end
  r
end

describe Backbite::Helper::Builder::Pyr::Element do
  
  before(:each) do
    @target = Backbite::Helper::Builder::Pyr::Element
    @simple = @target.new(:foo, :foo => :bar, :baz => :bum)
  end
  
  it "should be able to build an element" do
    r = @target.new(:foo)
    r.name.should == :foo
    r.value.should == ''
    r.args.should == []
    r.path_length.should == 0
  end

  it "should be able to build an element via Element[:name]" do
    r = @target[:foo]
    r.name.should == :foo
    r.value.should == ''
    r.args.should == []
    r.path_length.should == 0
  end
  
  it "should be able to build an element with arguments" do
    @simple.args == { :foo => :bar, :baz => :bum}
  end

  it "should have no children" do
    @simple.children
  end

  it "should have no parent" do
    @simple.parent.should_not
  end

  it "should be able to recive children" do
    t = mkchildren(@target, :baz, 5)
    t.children.each do |chj|
      chj.parent.to_sym.should == :baz
    end
    t.inner_append(@simple, @simple)
    t.children.size.should == 7
    t + l=Pyr::Element.new(:keke)
    t.size.should == 8
    t.last.should == l
  end

  it "should be able to recive children via block" do
  end

  it "should be able to revice content" do
    @simple.value = 23
    @simple.value.should == "23"
  end

  it "should be able to replace itself" do
    r = @target.new(:keke)
    @simple.replace(r).should == r
  end
  
end

describe Backbite::Helper::Builder::Pyr::Elements do

  include Backbite::Helper::Builder::Pyr

  before(:each) do
    @target = Pyr::Elements
    @ele = Pyr::Element.new(:foo, :foo => :bar, :baz => :bum)
  end
  
  it "should be able to build elements" do
    r = @target.new
    3.times{ r << @ele.clone}
    r.size.should == 3
    r.all?{ |r| r.name == :foo}.should
  end

  it "should return a single item" do
    r = @target.new
    3.times{ r << @ele.clone}
    r << ne=Pyr::Element.new(:bar)
    r.size.should == 4
    r[:bar].should == ne
  end

  it "should respond to include? by Symbol/String/Element" do
    r = @target.new
    3.times{ r << @ele.clone}
    r << ne=Pyr::Element.new(:bar)
    r.include?('bar').should
    r.include?(:bar).should
    r.include?(ne).should
  end
  
  it "should return a multible items on ambiguous selection" do
    r = @target.new
    3.times{ r << @ele.clone}
    r << ne=Pyr::Element.new(:bar)
    r[:foo].size.should == 3
  end

  it "should return a single item if Element is given" do
    r = @target.new
    3.times{ r << @ele.clone}
    r << ne=Pyr::Element.new(:bar)
    r[ne].should == ne
  end

  it "should be possible to remove an Element" do
    r = @target.new
    ne=Pyr::Element.new(:keke)
    r << ne
    3.times{ r << @ele.clone}
    r.delete(ne)
    r.size.should == 3
  end
  
  it "should return a single item on numeric" do
    r = @target.new
    r << Pyr::Element.new(:bum)
    3.times{ r << @ele.clone}
    r[0].should == :bum
  end
  
  it "toplevel elements added should have no parents" do
    r = @target.new
    3.times{ r << @ele.clone}
    r.any?{ |e| e.parent}.should_not
  end

  it "child elements should have parents" do
    t = nil
    r = @target.new
    3.times{ r << t=@ele.clone}
    r.each { |ele| ele.children.parent.should == :foo }
  end

  it "child elements added should have parents" do
    r = @target.new
    r << @ele
    r.first.inner_append(ne = Pyr::Element.new(:bumm))
    r.first[:bumm].should == ne
    r.first[:bumm].parent.name.should == :foo
    r.first[:bumm].path_length.should == 1
  end
end

describe Backbite::Helper::Builder::Pyr::Builder do
  include Backbite::Helper::Builder::Pyr

  it "should be able to build a simple tree of elements" do
    t = Pyr.build(&simple)
    t[:b][:s].should == :s
    t[:b][:s].parent.should == t[:b]
    t[:foo].first.should == :asd
    t[:foo].last.should == :baz
  end

  it "should be able to build a more complex tree of elements" do
    t = Pyr.build(&default)
    t[:html].size.should == 2
    t[:html][:body][:div].size.should == 4
  end

  it "should be able to build a tree from an Element" do
    r = Pyr::Element.new(:html).build{ head{ title "foo"}}
    r[:head].include?(:title).should
    r[:head].size.should == 1
  end
end

describe Backbite::Helper::Builder::Pyr::Outputter do
  include Backbite::Helper::Builder::Pyr

  it "should make html for a single Element" do
    Pyr::Element.new(:bar, :keke => 23).to_html.should ==
      "<bar keke=\"23\"></bar>"
  end

  it "should make html for complex" do
    Pyr.build(&default).to_html.should ==
      '<html><head><title>mytitle</title></head><body>'+
      '<div deine="mama"><a class="foo" href="foo"></a>'+
      '</div><div><a class="foo" href="foo"></a></div>'+
      '<div><a class="foo" href="foo"></a><a class="foo"'+
      ' href="foo"></a><a class="foo" href="foo"></a>'+
      '<a class="foo" href="foo"></a><a class="foo" '+
      'href="foo">a</a></div><div><div><ul><li>la</li>'+
      '<li>lu</li></ul></div></div></body></html>'
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
