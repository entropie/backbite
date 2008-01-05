#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

include Backbite::Helper::Builder

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
    @std['/body/div/p/ul/'].first.parent.name.should == :p
    @std['/body/div/p/../'].name == :div
    @std['/body/']['/p'].size == 3
    #puts @std.to_html
  end

  it "should accessible through symbols" do
    @std['/body'][:p].size.should == 3
    @std['/body'][:div].size.should == 1
  end

  it "should respond to #children" do
    @std['/body/a/a'].children.size == 7
    @std['/body/a'].children.size == 3
    @std['/head'].children.size == 1
  end

  it "should respond to #parent" do
    @std['/head/title'].first.parent.name.should == :head
  end

  it "should be possible to replace the inner_text" do
    @std['/head/title'].value = 23
    @std['/head/title'].value.should == "23"
  end
  
  it "should have a path length" do
    @std.first.path_length.should == 1
    @std['/head/title'].first.path_length.should == 2
    @std['/body/div/p/ul'].path_length.should == 4
  end

  it "should be possible to prepend/append elements (Elements)" do
    @std['/head'].first.prepend{ meta(:foo => :bar) { 'a' } }
    a=@std['/head'].last.append{ bum(:foo => :bar) { 'a' } }
    nospaces(a.to_html, "\n  <head>\n<meta foo=\"bar\"></meta>\n\n    <title>mytitle</title>\n\n<bum foo=\"bar\"></bum>\n</head>\n")
  end

  it "should be possible to append elements the simple way(Element)" do
    @std['/head'].first.foobar{ d "asd"}
    @std['/head'].first.keys.should == [:title, :foobar]
  end

  it "should be possible to replace elements by Pyr::Element" do
    html = Pyr.new.build{
      html { 
        title "foobaaaar"
        batz "bum"
        miao "buma"
      }
    }
    @std[:head].first.replace(html)
    nospaces(@std[:head].to_html, "\n  <head>\n<html>\n  <title>foobaaaar</title>\n\n  <batz>bum</batz>\n\n  <miao>buma</miao>\n</html>\n</head>\n")
  end

  it "should be possible to replace elements by block" do
    @std[:head].first.replace{ title 'asdfg'; meta 'bzmm'  }
    nospaces(@std[:head].to_html, "\n  <head>\n    <title>asdfg</title>\n\n    <meta>bzmm</meta>\n</head>\n")
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
