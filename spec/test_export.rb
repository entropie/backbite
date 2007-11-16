#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

target = Ackro::Tumblelog.new(:rspec, $default_config)
target.repository.setup!


describe Ackro::Repository::Export::HTML do

  result = target.repository.export(:html, :title => :foobar).hpricot
  
  it "result should have a doctype" do
    result.to_s.split("\n").first.should =~ /^<!DOCTYPE/
  end

  it "result should have a title" do
    ((result/:head/:title).html).should == 'foobar'
  end

  it "result should have some linke tags" do
    ((result/:head/:link).to_a.map{ |l| l.to_s }.grep(/\.css/).size).
      should == 2
  end

  it "result should have some javascript tags" do
    ((result/:head/:script).to_a.map{ |l| l.to_s }.grep(/\.js/).size).
      should == 2
  end

  it "result should have a body tag with (node) contents" do
    t = (result/:body/:div/:/)
    # p t.size
    # t.each { |at|
    #   puts at
    # }
    
    #((t/:p).html).should == "\n\n    "
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
