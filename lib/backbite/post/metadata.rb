#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  class Post
    # Every time we write a file to disk, we create a new Metadata
    # instance to save additional information about the nut.
    #
    # * component -- name of the component
    # * way -- the way the Post was created.
    # * date -- creation time
    class Metadata < Hash

      include Helper

      # +params+ must include <tt>:component</tt> and <tt>:way</tt>
      def initialize(meta, params = { })
        # we only need the name
        @component = params.delete(:component)
        params[:component] = @component.name

        @meta = meta
        params.extend(ParamHash).
          process!(:component => :required, :way => :required)
        replace(params)
        add_defaults
      end

      def inspect
        "(Meta: [#{keys.join(',')}])"
      end

      private
      def add_defaults
        if @meta
          Info << "Meta: merging #{ @meta.map{ |k,v| "#{k}=#{v}"}}"
          merge!(@meta)
        end
        self[:pid]  = @component.tlog.posts.next_id
        self[:date] ||= Time.now
      end
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
