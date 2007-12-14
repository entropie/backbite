#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Post::Export::LATEX

    def to_latex
      $KCODE = 'u'
      ordered = tlog.components[self.metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }
      res = ""
      res << "\\item #{identifier}\n"
      res << "\\begin{description}\n"
      ordered.each do |field|
        filtered = field.apply_filter(:latex).gsub(/([öüä])/, '')
        res << "\\item[#{field.to_sym}] #{filtered}\n"
      end
      res << "\\end{description}\n"
      res << "\n"
      res
    end

  end

  module Repository::Export::LATEX # :nodoc: All

    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      @tree.write
      #puts @tree
      @tree
    end

    class Tree < Repository::ExportTree

      def initialize(tlog, params)
        @latex_file = File.expand_path('~/backbite.tex')
        super
        @file = 'backbite.dvi'
        make_tree
        tempfile_write
        @__result__ = to_dvi
      end

      def tempfile_write
        @dvifile = tmpfile = tlog.repository.join('tmp', 'latex.out.tex')
        tmpfile.open('w+'){ |t| t.write(@result) }
      end

      def to_dvi
        unless written?
          `latex -output-directory=#{ @dvifile.dirname } #{@dvifile.to_s}`
        end
        @dvifile.dirname.join('latex.out.dvi').open('r').readlines.to_s
      end

      alias :to_s :to_dvi

      def body
        posts =
          if psopts = @params[:postopts]
            tlog.posts.dup.filter(@params.dup.merge(psopts))
          else
            tlog.posts.dup
          end
        ord = @tlog.config[:html][:body].
          order.reject{ |o|
          Repository::IgnoredBodyFields.include?(o)
        }
        ret = ''
        ord.each do |n|
          v = @tlog.config[:html][:body][n]
          ret << "\\subsection{#{n}}\n\n"
          ret = "\\flushleft\n"
          ret << "\\begin{enumerate}\n"      
          ps = @params.dup.merge(:tree => self)
          psts = posts.by_date!.reverse.
            with_export(:latex, ps)
          #:target => post.config[:target]
          psts.each do |post|
            ret << post.to_latex
          end
          ret << "\\end{enumerate}\n"
        end
        ret
      end

      def make_tree
        skel = Pathname.new(@latex_file).readlines.join
        make_body(skel)
      end

      def make_body(skel)
        @result = skel.to_s.gsub(/BODY/, body)
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
