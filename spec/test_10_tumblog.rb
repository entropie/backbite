#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Tumblelog do

  before(:all) do
    system('rm -rf /tmp/rspec')
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end

  it "should be createable" do
    @target.repository.setup!
  end
  
  it "should respond with non nil on various attributes" do
    p @target
    [:repository, :config, :name, :root, :path,
     :author, :url, :components, :posts, :post].each do |attr|
      @target.should.respond_to?(attr)
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
