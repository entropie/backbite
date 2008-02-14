#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'iconv'
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_latex'

require 'hpricot' # FIXME: no need
$KCODE = 'u'

module Backbite

  module Post::Export::LATEX
    
    def convert_lang(str)
      str.gsub!(/#/, '\#')
      str.gsub!(/_/, '\_')
      str
    end
    
    def convert_field(str, field)
      if(field.definitions[:markup] and mu = field.definitions[:markup][:html]).kind_of?(Symbol)
        return Hpricot.parse(field.apply_markup(mu, str)).to_plain_text
      elsif not field.has_filter?(:latex)
        h = SM::ToLaTeX.new
        sm = SM::SimpleMarkup.new
        return sm.convert(str.to_s, h)
      else
        str
      end
    end

    def to_latex
      res = ""
      res << "\\subsubsection{Identifier: #{identifier}}\n"
      res << "\\flushleft\n"      
      res << "\\begin{description}\n"      
      res << "\\begin{enumerate}\n"
      fields.each do |field|
        field = fields[field]
        next if field.to_sym == :permalink
        filtered = field.apply_filter(:latex)
        filtered = convert_field(filtered, field)
        filtered = convert_lang(filtered)
        res << "\\item[#{field.to_sym}:] #{filtered}\n"
      end
      res << "\\end{enumerate}\n"
      res << "\\end{description}\n"
      res << "\n"
      res
    end

  end

  module Repository::Export::LATEX
    
    def self.clean!(tlog, params)
      (td = tlog.repository.join('tmp')).entries.grep(/latex\.out/).each do |tf|
        td.join(tf).unlink
      end
    end
    
    def self.export(tlog, params)
      [:dvi, :pdf].each do |ext|
        @tree = Tree.new(ext, tlog, params)
        @tree
      end
    end

    class Tree < Repository::ExportTree

      def initialize(ext, tlog, params)
        @latex_file = tlog.repository.join('misc', 'backbite.tex')
        @ext = ext
        super(tlog, params)
        @file = "#{tlog.name}.#{@ext}"
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
        @dvifile.dirname.join("latex.out.#{@ext}").open('r').readlines.to_s
      end

      def default_options
        %Q(
\\usepackage{hyperref}
)
      end
      
      def pdf_options
        %Q(
\\usepackage[pdfauthor={AUTHOR},%
             pdftitle={TITLE},%
             unicode={true},%
             pdftex]{hyperref}
\\hypersetup{colorlinks,%
  citecolor=black,%
  filecolor=black,%
  linkcolor=blue,%
  urlcolor=blue,%
  pdftex}
)
      end
      
      def options
        case @ext
        when :pdf
          pdf_options
        else
          default_options
        end
      end
      
      alias :to_s :to_dvi

      def body
        ret = ''
        posts = tlog.posts + tlog.archive
        ns = @tlog.config[:html][:body].order.reject{ |o|
          (@tlog.config[:html][:body][o][:plugin].kind_of?(Symbol) or
           Repository::IgnoredBodyFields.include?(o))
        }
        ns.each do |n|
          ret << "\\subsection{Node: #{n}}\n\n"
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
        result.gsub!(/OPTIONS/, options)        
        result.gsub!(/TITLE/, tlog.title)
        result.gsub!(/AUTHOR/, tlog.author.to_s)
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
