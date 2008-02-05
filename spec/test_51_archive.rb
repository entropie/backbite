#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe Backbite::Archive do
  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end
  
  it "should have archived posts" do
    post = @target.post(:bar, :hash =>
                        { :topic => 'keke',
                          :body  => 'foo ahash',
                          :tags  => 'bar'
                        },
                        :meta  => { :date => Time.now-((3*24*60*60)+(23**5)) })
    post.save
    pp post.to_post
    @target.archive.size.should == 5
    # @target.archive.days(2008).map{ |pf|
    #   p Backbite::Post.read(@target, pf)
    # }
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
