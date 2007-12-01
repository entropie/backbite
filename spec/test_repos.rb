#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Repository do

  before(:each) do
    @target = Backbite::Repository.new(:rspec, '~/Tmp/rspec')
  end

  it "should able to target a nonexistant directory" do
    @target.valid?.should_not
  end

  it "should able to build a directory structure" do
    @target.setup!
    @target.valid?.should
  end

  it "should able to remove a directory structure" do

    system("mkdir -p /home/mit/public_html/backbite/")
    system("cp -R #{ @target.directory }/* /home/mit/public_html/backbite/")

    @target.remove!
    @target.valid?.should_not
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
