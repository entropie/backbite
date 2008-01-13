#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Settings do

  before(:all) do
    @config = Backbite::Settings.read('spec/.spec_skel/default_config.rb')
  end
  
  it "should parse the config string to a hash" do
    @config.should
    # pp @config[:defaults][:root]
    # @config.class.should == Hash
  end

  it "should take care of the order of inserting" do
    @config.first.first.should == ["/tmp/rspec"]
    # @config.sort.first.first.should == :defaults
    # @config.sort.last.first.should  == :html
    # @config[:html].sort.first.first.should == :body
  end

  it "should replace values of the hash" do
    # @config.with_replacer[:defaults][:title].
    #   should == "rspec"
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
