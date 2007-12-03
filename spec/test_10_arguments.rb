#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Optionparser do

  before(:all) do
    @tlog = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')

    Backbite.optionparser(@tlog) do |op|
      op.keyword(:test, Object.new) do |op, handler|
        op.declare(:single) { :single  }
        op.declare(:one) { |a| a }
        op.declare(:two) { |a,b| [a,b] }
        op.declare(:three) { |a,b,c| [a,b,c] }
      end
      op.keyword(:bar, Object.new) do |op, handler|
        op.declare(:single) { :single  }
        op.declare(:one) { |a| a}
        op.declare(:two) { |a,b| [a,b] }
        op.declare(:three) { |a,b,c| [a,b,c] }
      end
    end
    
  end

  it "should not respond to foo" do
    Backbite.run_options(@tlog, 'test').should_not
  end

  it "should respond to a single argument" do
    [:test, :bar].each do |fk|
      Backbite.run_options(@tlog, fk, 'single').should == [:single]
    end
  end

  it "should respond to a multible arguments" do
    Backbite.run_options(@tlog, 'test', 'single', 'bar', 'single').
      should == [:single, :single]
  end

  it "should respond to a single argument with parameters" do
    [:test, :bar].each do |fk|
      Backbite.run_options(@tlog, fk, 'one', 'a').should == ["a"]
    end
  end

  it "should respond to a argument with multible parameters" do
    [:test, :bar].each do |fk|
      Backbite.run_options(@tlog, fk, 'two', 'a', 'b').should == ["a", "b"]
    end
  end

  it "should respond to multible arguments with multible parameters" do
    [[:test, :bar], [:bar, :test]].each do |fk, fkt|
       Backbite.
         run_options(@tlog, fk, 'two', 'a', 'b', fkt, "three", "a","b","c").
         should == ["a", "b", "a", "b", "c"]
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
