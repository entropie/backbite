#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Post::Export::LATEX
  end

  module Repository::Export::LATEX # :nodoc: All

    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      puts @tree
      @tree

    end

    class Tree < Repository::ExportTree

      LatexSkel =
        [
         [:documentclass, "(12pt)"],
         [:begin, "{document}"],
         [:BODY, '%%%body%%%'],
         [:end, "{document}"]
        ]

      def initialize(tlog, params)
        super
        @result = ''
        make_tree
      end

      def make_tree
        LatexSkel.each do |n, v|
          @result << "#{(n == :BODY ? '' : "\\#{ n }")}#{v}\n"
        end
      end
      
      def to_latex
        @result.to_s
      end
      alias :to_s :to_latex
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
