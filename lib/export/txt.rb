#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Ackro

  module Post::Export::TXT

    def filter(field)
      if field.respond_to?(:plugin)
        plugin = field.plugin
        plugin.field = field
        if plugin.respond_to?(:txt_filter) and res = plugin.txt_filter
          return res
        elsif plugin.respond_to?(:filter) and res = plugin.filter
          return res
        end
      end
      field.value
    end
    
    def to_txt
      str = '{{{'
      ordered = tlog.components[self.metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }
      ordered.inject(str) do |m, field|
        f, filtered = field.to_sym, filter(field)
        m << "\n %-10s %s " % [f, filtered]
      end
    end

  end
  

  module Repository::Export::TXT

    # mount point
    def self.export(tlog, params)
      Tree.new(tlog, params)
    end
    
    class Tree

      attr_reader :tlog, :hpricot, :timestamp
      
      def initialize(tlog, params)
        @tlog, @params = tlog, params
        @timestamp = Time.new
        @str = "###\n### ''#{params[:title]}`` at '#{timestamp}'\n###\n\n"
        @tlog.posts(params[:postopts]).with_export(:txt){ |post|
          @str << "### " << post.metadata[:date].to_s << "\n"
          @str << post.to_txt << "\n"
        }
      end

      def to_s
        @str
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
