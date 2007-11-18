#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Tumblelog do

  before(:each) do
    @target = Backbite::Tumblelog.new(:rspec, $default_config)
    @target.repository.setup!
  end

  it "should respond with non nil on various attributes" do
    [:repository, :config, :name, :root, :path,
     :author, :url, :components, :posts, :post].each do |attr|
      @target.should.respond_to(attr)
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
