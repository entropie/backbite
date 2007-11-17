#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

target = Ackro::Tumblelog.new(:rspec, $default_config)
target.repository.setup!

describe Ackro::Repository::Export::CSS do

  result = target.repository.export(:css).to_s

  it "should include basic tlog style definitions" do
    result.should =~ /CSS file:.*\/base\.css/
    result.should =~ /^body \{/
    result.should =~ /^  #red \{/
    result.should =~ /^  #black \{/
    result.should_not =~ /^  #style \{/
  end

  it "should include basic component style definitions" do
    result.should =~ /CSS file:.*\/generated\.css/
    result.should =~ /    #black > \.test \{/
    result.should =~ /    #red > \.foo \{/
    result.should_not =~ /    #style/      
  end

  it "should include component field style definitions" do
    result.should =~ /    #black > \.test > \.topic/
    result.should =~ /    #black > \.test > \.tags/
    result.should =~ /    #black > \.test > \.body/
    result.should =~ /    #black > \.test > \.date/
    result.should =~ /    #red > \.foo > \.topic/
    result.should =~ /    #red > \.foo > \.tags/
    result.should =~ /    #red > \.foo > \.body/
    result.should =~ /    #red > \.foo > \.date/
  end

end

describe Ackro::Repository::Export::HTML do

  result = target.repository.export(:html, :title => :foobar).hpricot
  
  it "result should have a doctype" do
    result.to_s.split("\n").first.should =~ /^<!DOCTYPE/
  end

  it "result should have a title" do
    ((result/:head/:title).html).should == 'foobar'
  end

  it "result should have some (meta)link tags" do
    ((result/:head/:link).to_a.map{ |l| l.to_s }.grep(/\.css/).size).
      should == 2
  end

  it "result should have some javascript tags" do
    ((result/:head/:script).to_a.map{ |l| l.to_s }.grep(/\.js/).size).
      should == 2
  end

  it "result should have a body tag with (node) contents" do
    (result/:body/:div/'> *').size.should == 5
    (result/:body/:p).size.should == 1
    (result/:body/'> p').size.should == 1
    (result/:body/'> div'/'> *').size.should == 5
  end


  # it "" do
  #   puts
  #   puts "-"*60
  #   puts result
  # end
  
end

describe Ackro::Repository::Export::TXT do

  result = target.repository.export(:txt, :title => :foobar).to_s
  
  it "result should have a title" do
    result.split("\n")[1].should =~
      /### ''foobar`` at '.+'/
  end

  # it "" do
  #   puts
  #   puts "-"*60
  #   puts result
  # end
  
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
