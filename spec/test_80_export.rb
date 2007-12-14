#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe "Backbite::Repository::Export::CSS" do

  before(:all) do
    target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:css).to_s
  end

  it "should include basic tlog style definitions" do
    @result.should =~ /CSS file:.*\/base\.css/
    @result.should =~ /^body \{/
    @result.should =~ /^  #red \{/
    @result.should =~ /^  #black \{/
    @result.should_not =~ /^  #style \{/
  end

  it "should include basic component style definitions" do
    @result.should =~ /CSS file:.*\/generated\.css/
    @result.should =~ /    #black > \.test \{/
    @result.should =~ /    #red > \.foo \{/
    @result.should_not =~ /    #style/      
  end

  it "should include component field style definitions" do
    @result.should =~ /    #black > \.test > \.topic/
    @result.should =~ /    #black > \.test > \.tags/
    @result.should =~ /    #black > \.test > \.body/
    @result.should =~ /    #black > \.test > \.date/
    @result.should =~ /    #red > \.foo > \.topic/
    @result.should =~ /    #red > \.foo > \.tags/
    @result.should =~ /    #red > \.foo > \.body/
    @result.should =~ /    #red > \.foo > \.date/
    @result.should =~ /background\-color:silver/
  end

  it "should include haml style definitions" do
    @result.should =~ /\.permalink \.pl \{/
    @result.should =~ /#red \.permalink \.pl \{/
  end
end

describe "Backbite::Repository::Export::HTML" do

  before(:all) do
    target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:html, :title => :foobar).hpricot
  end
  
  it "result should have a doctype" do
    @result.to_s.split("\n").first.should =~ /^<!DOCTYPE/
  end

  it "result should have a title" do
    ((@result/:head/:title).html).to_s.should == 'foobar'
  end

  it "result should have some (meta)link tags" do
    ((@result/:head/:link).to_a.map{ |l| l.to_s }.grep(/\.css/).size).
      should == 3
  end

  it "result should have some javascript tags" do
    ((@result/:head/:script).to_a.map{ |l| l.to_s }.grep(/\.js/).size).
      should == 2
  end

  it "result should have a body tag with (node) contents" do
    (@result/:body/:div/'> *').size.should == 15
    (@result/:body/'> div'/'> *').size.should == 15
  end

end

describe "Backbite::Repository::Export::TXT" do

  before(:all) do
    target = Backbite::Tumblelog.new(:txt, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:txt, :title => :foobar).to_s
  end
  
  it "result should have a title" do
    @result.split("\n")[1].should =~
      /# Title: foobar/
  end

  it "should have some posts" do
    @result.scan(/^#/).flatten.size.should == 7
    @result.scan(/^[A-Z][a-z]+ \{/).flatten.size.should == 12
    @result.scan(/^\}/m).flatten.size.should == 12
  end
  
end

describe "Backbite::Repository::Export::TAGS" do

  before(:all) do
    target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:tags).to_s
  end
  
  it "result should be big" do
    @result.size.should > 5000
  end

  it "result titles should include tag titles" do
    ex = ["batz", "bar", "bumm", "ahash", "nana", "file", "another", "keke"]
    r = @result.scan(/title>(.+)<\/title>/).flatten.map{ |r| r[/: (\w+)/, 1] }
    r.each do |t|
      ex.include?(t).should
    end
  end

end

describe "Backbite::Repository::Export::TAGS" do

  before(:all) do
    target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:latex).to_s
  end
  
  it "result should be big" do
    @result.size.should > 4000
  end

end


describe "Backbite::Repository::Export::ARCHIVE" do

  before(:all) do
    target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
    @result = target.repository.export(:archive).to_s
  end
  
  it "result should be big" do
    @result.should
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
