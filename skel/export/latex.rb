#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'iconv'

$KCODE = 'u'

module Backbite

  module Post::Export::LATEX

    def convert_field(str)
      str.gsub(/([öüä])/) do |r|
        w = "\\\"" << r.to_s
        r = Iconv.iconv("ascii//translit", "ISO-8859-1", w)
        r
      end
    end
    
    def to_latex
      ordered = tlog.components[self.metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }
      res = ""
      res << "\\subsubsection{Identifier: #{identifier}}\n"
      res << "\\flushleft\n"      
      res << "\\begin{description}\n"      
      res << "\\begin{enumerate}\n"      
      #res << "\\item asd\n"
      ordered.each do |field|
        #next if field.to_sym == :permalink
        filtered = field.apply_filter(:latex)
        filtered = convert_field(filtered)
        res << "\\item[#{field.to_sym}:] #{filtered}\n"
      end
      res << "\\end{enumerate}\n"
      res << "\\end{description}\n"
      res << "\n"
      res
    end

  end

  module Repository::Export::LATEX # :nodoc: All

    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      #puts @tree
      @tree
    end

    class Tree < Repository::ExportTree

      def initialize(tlog, params)
        @latex_file = File.expand_path('~/backbite.tex')
        super
        @file = 'backbite.dvi'
        @result = make_tree
        tempfile_write
        @__result__ = to_dvi
        write        
      end

      def tempfile_write
        @dvifile = tmpfile = tlog.repository.join('tmp', 'latex.out.tex')
        tmpfile.open('w+'){ |t| t.write(@result) }
      end

      def to_dvi
        Info << "[2 times] cd #{ @dvifile.dirname } && latex #{@dvifile.to_s}"
        1.upto(2) do |i|
          `cd #{ @dvifile.dirname } && latex #{@dvifile.to_s}`
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
          ret << "\\section{Node: #{n}}\n\n"
          ps = @params.dup.merge(:tree => self)
          psts = posts.filter(:target => n).by_date!.reverse.
            with_export(:latex, ps)
          psts.each do |post|
            ret << post.to_latex
          end
        end
        ret
      end

      def make_tree
        skel = Pathname.new(@latex_file).readlines.join
        make_body(skel)
      end

      def make_body(skel)
        result = skel.to_s.gsub(/BODY/, body)
        result.gsub!(/TITLE/, tlog.title)
        result.gsub!(/AUTHOR/, tlog.author.to_s)
        result
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
