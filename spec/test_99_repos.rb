#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

describe "Finish" do
  before(:all) do
    @target = Backbite::Tumblelog.new(:rspec, 'spec/.spec_skel/default_config.rb')
  end

  it "should remove everything" do
    system("mkdir -p /home/mit/public_html/backbite/")
    system("cp -R #{ @target.root }/* /home/mit/public_html/backbite/")
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
