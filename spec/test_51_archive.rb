#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Archive do
  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end
  
  it "should have archived posts" do
    @target.archive.size.should == 5
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
