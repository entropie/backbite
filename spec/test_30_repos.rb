#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Repository do

  before(:all) do
    @target = Backbite::Repository.new(:rspec, '~/Tmp/rspec')
  end

  it "should able to target a nonexistant directory" do
    @target.valid?.should_not
  end

  it "should able to build a directory structure" do
    @target.setup!
    @target.valid?.should
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
